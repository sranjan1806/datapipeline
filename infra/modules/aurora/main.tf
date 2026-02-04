resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-subnet-group"
  })
}

resource "aws_security_group" "aurora" {
  name        = "${var.name}-aurora-sg"
  description = "Aurora Postgres SG"
  vpc_id      = var.vpc_id

  # NO inbound yet (we'll allow from DMS + MWAA SGs later)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-aurora-sg" })
}

# Parameter group (basic; CDC-related params can be added later)
resource "aws_rds_cluster_parameter_group" "this" {
  name   = "${var.name}-aurora-pg"
  family = "aurora-postgresql15"

  # Keep minimal for MVP; we will add logical replication settings before CDC
  tags = merge(var.tags, { Name = "${var.name}-aurora-pg" })
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.name}-aurora"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version

  database_name   = var.db_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  storage_encrypted = true
  skip_final_snapshot = true  # MVP speed; later set false for production-like

  tags = merge(var.tags, { Name = "${var.name}-aurora" })
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.name}-aurora-writer-1"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  publicly_accessible = false

  tags = merge(var.tags, { Name = "${var.name}-aurora-writer-1" })
}
