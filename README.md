# datapipeline
My datapipeline projects and experiments

This pipeline demonstrates an end-to-end batch + CDC ingestion pattern using Aurora PostgreSQL, AWS DMS, and Amazon MWAA.
DMS performs an initial full load followed by continuous CDC into an S3 raw zone.
Airflow orchestrates data freshness and completeness checks before publishing validated data to a curated S3 zone.
All infrastructure is provisioned using Terraform.