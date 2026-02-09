from __future__ import annotations

from datetime import datetime, timedelta
from typing import Iterable

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.amazon.aws.operators.s3 import S3CreateObjectOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor


RAW_BUCKET = Variable.get("raw_bucket_name", default_var="replace-with-raw-bucket")
CURATED_BUCKET = Variable.get("curated_bucket_name", default_var="replace-with-curated-bucket")
RAW_PREFIX = Variable.get("raw_prefix", default_var="dms/raw/public/")
CURATED_PREFIX = Variable.get("curated_prefix", default_var="curated/public")
MIN_FILES = int(Variable.get("min_raw_files", default_var="1"))


def _is_data_file(key: str) -> bool:
    ignored_suffixes = (".json", ".json.gz", "_SUCCESS", ".keep")
    return not key.endswith(ignored_suffixes)


def list_raw_objects() -> list[str]:
    s3 = S3Hook(aws_conn_id="aws_default")
    return s3.list_keys(bucket_name=RAW_BUCKET, prefix=RAW_PREFIX) or []


def validate_raw_objects(**context) -> None:
    ti = context["ti"]
    keys: Iterable[str] = ti.xcom_pull(task_ids="list_raw_files") or []
    data_keys = sorted([k for k in keys if _is_data_file(k)])

    if len(data_keys) < MIN_FILES:
        raise ValueError(
            f"Validation failed: expected at least {MIN_FILES} data file(s), found {len(data_keys)}"
        )

    ti.xcom_push(key="validated_keys", value=data_keys)


def copy_to_curated(execution_date: str, **context) -> None:
    ti = context["ti"]
    validated_keys = ti.xcom_pull(task_ids="validate_raw_files", key="validated_keys") or []

    if not validated_keys:
        raise ValueError("No validated keys found to copy into curated zone")

    target_prefix = f"{CURATED_PREFIX}/dt={execution_date}"
    s3 = S3Hook(aws_conn_id="aws_default")

    for source_key in validated_keys:
        filename = source_key.rsplit("/", 1)[-1]
        target_key = f"{target_prefix}/{filename}"
        s3.copy_object(
            source_bucket_key=source_key,
            dest_bucket_key=target_key,
            source_bucket_name=RAW_BUCKET,
            dest_bucket_name=CURATED_BUCKET,
        )


default_args = {
    "owner": "data-platform",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="s3_freshness_check",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
    tags=["mvp", "dms", "s3"],
) as dag:
    wait_for_raw_files = S3KeySensor(
        task_id="wait_for_raw_files",
        bucket_name=RAW_BUCKET,
        bucket_key=f"{RAW_PREFIX}*",
        wildcard_match=True,
        poke_interval=60,
        timeout=60 * 30,
        aws_conn_id="aws_default",
    )

    list_raw_files = PythonOperator(
        task_id="list_raw_files",
        python_callable=list_raw_objects,
    )

    validate_raw_files = PythonOperator(
        task_id="validate_raw_files",
        python_callable=validate_raw_objects,
    )

    publish_to_curated = PythonOperator(
        task_id="publish_to_curated",
        python_callable=copy_to_curated,
        op_kwargs={"execution_date": "{{ ds }}"},
    )

    write_success_marker = S3CreateObjectOperator(
        task_id="write_success_marker",
        s3_bucket=CURATED_BUCKET,
        s3_key=f"{CURATED_PREFIX}/_SUCCESS/{{{{ ds_nodash }}}}",
        data="ok\n",
        replace=True,
        aws_conn_id="aws_default",
    )

    wait_for_raw_files >> list_raw_files >> validate_raw_files >> publish_to_curated >> write_success_marker
