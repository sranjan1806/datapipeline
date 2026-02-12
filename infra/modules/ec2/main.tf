data "aws_ami" "amazon_linux_2023" {
  count       = var.ami_id == null && var.os_family == "amazon-linux-2023" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "ubuntu_2204" {
  count       = var.ami_id == null && var.os_family == "ubuntu-22.04" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  selected_ami = coalesce(
    var.ami_id,
    var.os_family == "ubuntu-22.04" ? data.aws_ami.ubuntu_2204[0].id : data.aws_ami.amazon_linux_2023[0].id
  )
}

resource "aws_instance" "this" {
  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  user_data_replace_on_change = true

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size_gb
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    hostname  = var.hostname
    node_role = var.node_role
  })

  tags = merge(
    var.tags,
    {
      Name     = var.name
      Hostname = var.hostname
      Role     = var.node_role
    }
  )
}
