# ---------- Security Group for DMS ----------
resource "aws_security_group" "dms" {
  name        = "${var.name}-dms-sg"
  description = "DMS replication instance SG"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-dms-sg" })
}

# ---------- DMS Subnet Group ----------
resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_description = "DMS subnet group"
  replication_subnet_group_id          = "${var.name}-dms-subnets"
  subnet_ids                           = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-dms-subnets" })
}

# ---------- IAM role for DMS to write to S3 ----------
data "aws_iam_policy_document" "assume_dms" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dms_s3" {
  name               = "${var.name}-dms-s3-role"
  assume_role_policy = data.aws_iam_policy_document.assume_dms.json
  tags               = var.tags
}

data "aws_iam_policy_document" "dms_s3_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:DeleteObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.raw_bucket_name}",
      "arn:aws:s3:::${var.raw_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "dms_s3" {
  name   = "${var.name}-dms-s3-policy"
  policy = data.aws_iam_policy_document.dms_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "dms_s3_attach" {
  role       = aws_iam_role.dms_s3.name
  policy_arn = aws_iam_policy.dms_s3.arn
}

# ---------- Replication Instance ----------
resource "aws_dms_replication_instance" "this" {
  replication_instance_id    = "${var.name}-dms-repl"
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 50
  multi_az                   = false
  publicly_accessible        = false

  vpc_security_group_ids      = [aws_security_group.dms.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.replication_subnet_group_id

  tags = merge(var.tags, { Name = "${var.name}-dms-repl" })
}

# ---------- Source Endpoint (Aurora PostgreSQL) ----------
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.name}-src-aurora"
  endpoint_type = "source"
  engine_name   = "postgres"

  server_name   = var.aurora_endpoint
  port          = var.aurora_port
  database_name = var.aurora_db_name
  username      = var.replication_username
  password      = var.replication_password
  ssl_mode      = "require"

  tags = merge(var.tags, { Name = "${var.name}-src-aurora" })
}

# ---------- Target Endpoint (S3) ----------
resource "aws_dms_s3_endpoint" "target" {
  endpoint_id   = "${var.name}-tgt-s3"
  endpoint_type = "target"

  bucket_name   = var.raw_bucket_name
  bucket_folder = "dms/raw"

  compression_type        = "GZIP"
  data_format             = "parquet"
  parquet_version         = "parquet-2-0"
  service_access_role_arn = aws_iam_role.dms_s3.arn

  tags = merge(var.tags, { Name = "${var.name}-tgt-s3" })
}


# ---------- Replication Task (Full load + CDC) ----------
resource "aws_dms_replication_task" "this" {
  replication_task_id      = "${var.name}-task-full-cdc"
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.target.endpoint_arn

  # Start with "all tables" in one schema (we'll use appdb/public)
  table_mappings = jsonencode({
    rules = [
      {
        "rule-type" : "selection",
        "rule-id" : "1",
        "rule-name" : "1",
        "object-locator" : {
          "schema-name" : "public",
          "table-name" : "%"
        },
        "rule-action" : "include"
      }
    ]
  })

  # Keep it simple for MVP
  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema       = "",
      SupportLobs        = true,
      FullLobMode        = false,
      LobChunkSize       = 64,
      LimitedSizeLobMode = true,
      LobMaxSize         = 32
    },
    FullLoadSettings = {
      TargetTablePrepMode = "DROP_AND_CREATE"
    },
    Logging = {
      EnableLogging = true
    }
  })

  tags = merge(var.tags, { Name = "${var.name}-task-full-cdc" })
}
