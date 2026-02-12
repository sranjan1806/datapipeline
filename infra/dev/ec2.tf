resource "aws_security_group" "postgres_nodes" {
  name        = "${var.name}-postgres-nodes-sg"
  description = "Shared SG for PostgreSQL EC2 nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow PostgreSQL traffic among cluster nodes"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-postgres-nodes-sg"
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}

module "ec2_writer" {
  source = "../modules/ec2"

  name                   = "${var.name}-ec2-1"
  hostname               = "pg-primary"
  node_role              = "Writer"
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.postgres_nodes.id]
  ami_id                 = var.ec2_ami_id
  os_family              = var.ec2_os_family
  key_name               = var.ec2_key_name
  root_volume_type       = var.ec2_root_volume_type
  root_volume_size_gb    = var.ec2_root_volume_size_gb

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}

module "ec2_replica1" {
  source = "../modules/ec2"

  name                   = "${var.name}-ec2-2"
  hostname               = "pg-replica1"
  node_role              = "Replica1"
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.private_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.postgres_nodes.id]
  ami_id                 = var.ec2_ami_id
  os_family              = var.ec2_os_family
  key_name               = var.ec2_key_name
  root_volume_type       = var.ec2_root_volume_type
  root_volume_size_gb    = var.ec2_root_volume_size_gb

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}

module "ec2_replica2" {
  source = "../modules/ec2"

  name                   = "${var.name}-ec2-3"
  hostname               = "pg-replica2"
  node_role              = "Replica2"
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.postgres_nodes.id]
  ami_id                 = var.ec2_ami_id
  os_family              = var.ec2_os_family
  key_name               = var.ec2_key_name
  root_volume_type       = var.ec2_root_volume_type
  root_volume_size_gb    = var.ec2_root_volume_size_gb

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = var.name
  }
}
