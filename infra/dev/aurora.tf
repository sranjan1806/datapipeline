locals {
  aurora_cluster_parameter_overrides = {
    # Keep explicit here so environment-level tuning is easy later.
    "rds.logical_replication" = "1"
    max_replication_slots     = "10"
    max_wal_senders           = "10"
  }
}

module "aurora" {
  source = "../modules/aurora"

  name               = var.name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name                     = "appdb"
  master_username             = "masteruser"
  master_password             = var.db_master_password
  cluster_parameter_overrides = local.aurora_cluster_parameter_overrides

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}

resource "aws_security_group_rule" "aurora_allow_dms" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.aurora.security_group_id
  source_security_group_id = module.dms.dms_sg_id
  description              = "Allow DMS to connect to Aurora"
}
