from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.providers.amazon.aws.operators.s3 import S3CreateObjectOperator

BUCKET = "YOUR_RAW_BUCKET"
RAW_PREFIX = "dms/raw/your_table/"
CURATED_PREFIX = "curated/your_table/"

default_args = {
    "owner": "shashi",
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

    wait_for_files = S3KeySensor(
        task_id="wait_for_raw_files",
        bucket_name=BUCKET,
        bucket_key=f"{RAW_PREFIX}*",
        wildcard_match=True,
        poke_interval=60,
        timeout=60 * 30,
    )

    success_marker = S3CreateObjectOperator(
        task_id="write_success_marker",
        s3_bucket=BUCKET,
        s3_key=f"{CURATED_PREFIX}_SUCCESS/{{{{ ds }}}}",
        data="ok\n",
        replace=True,
    )

    wait_for_files >> success_marker
