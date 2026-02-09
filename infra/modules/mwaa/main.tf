locals {
  airflow_bucket_name = "${var.name}-airflow-${var.unique_suffix}"
}

resource "aws_s3_bucket" "airflow" {
  bucket = local.airflow_bucket_name
  tags   = merge(var.tags, { Name = local.airflow_bucket_name, Service = "mwaa" })
}

resource "aws_s3_bucket_public_access_block" "airflow" {
  bucket                  = aws_s3_bucket.airflow.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "airflow" {
  bucket = aws_s3_bucket.airflow.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "airflow" {
  bucket = aws_s3_bucket.airflow.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "dags_prefix" {
  bucket  = aws_s3_bucket.airflow.id
  key     = "dags/.keep"
  content = "placeholder"
}

data "aws_iam_policy_document" "assume_mwaa" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["airflow.amazonaws.com", "airflow-env.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mwaa_execution" {
  name               = "${var.name}-mwaa-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_mwaa.json
  tags               = var.tags
}

data "aws_iam_policy_document" "mwaa_execution" {
  statement {
    sid = "AllowAirflowBucket"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.airflow.arn,
      "${aws_s3_bucket.airflow.arn}/*"
    ]
  }

  statement {
    sid = "AllowRawAndCuratedDataBuckets"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      var.raw_bucket_arn,
      "${var.raw_bucket_arn}/*",
      var.curated_bucket_arn,
      "${var.curated_bucket_arn}/*"
    ]
  }

  statement {
    sid = "AllowCloudWatchLogs"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]

    resources = ["arn:aws:logs:*:*:log-group:airflow-${var.name}-*"]
  }

  statement {
    sid = "AllowMetricsAndSqs"

    actions = [
      "cloudwatch:PutMetricData",
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "mwaa_execution" {
  name   = "${var.name}-mwaa-execution-policy"
  policy = data.aws_iam_policy_document.mwaa_execution.json
}

resource "aws_iam_role_policy_attachment" "mwaa_execution" {
  role       = aws_iam_role.mwaa_execution.name
  policy_arn = aws_iam_policy.mwaa_execution.arn
}

resource "aws_security_group" "mwaa" {
  name        = "${var.name}-mwaa-sg"
  description = "MWAA security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-mwaa-sg" })
}

resource "aws_mwaa_environment" "this" {
  name               = "${var.name}-mwaa"
  airflow_version    = var.airflow_version
  environment_class  = var.environment_class
  execution_role_arn = aws_iam_role.mwaa_execution.arn

  source_bucket_arn = aws_s3_bucket.airflow.arn
  dag_s3_path       = "dags"

  webserver_access_mode = var.webserver_access_mode

  min_workers = var.min_workers
  max_workers = var.max_workers
  schedulers  = var.schedulers

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.private_subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-mwaa"
  })

  depends_on = [
    aws_s3_object.dags_prefix,
    aws_iam_role_policy_attachment.mwaa_execution
  ]
}
