terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}

# Master password: generated inside Terraform, delivered to the app via SSM
# SecureString — it never appears in tfvars, the repo, or task definitions.
# (State still holds it; the S3 backend is encrypted and access-controlled.)
resource "random_password" "master" {
  length  = 24
  special = false
}

#tfsec:ignore:aws-ssm-secret-use-customer-key -- default aws/ssm key is sufficient here; a CMK adds USD 1/month
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.name}/db/password"
  type  = "SecureString"
  value = random_password.master.result

  tags = var.tags
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.name}-"
  subnet_ids  = var.db_subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-db-subnets" })
}

resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "Database tier: ingress only from the app tier, no egress"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-db-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from app tier only"
  referenced_security_group_id = var.app_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_db_instance" "this" {
  identifier_prefix = "${var.name}-"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.username
  password = random_password.master.result
  port     = 5432

  iam_database_authentication_enabled = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_days
  # Controlled per env: on in prod, off in ephemeral dev so destroy works.
  #tfsec:ignore:AVD-AWS-0177
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final"

  auto_minor_version_upgrade = true
  apply_immediately          = true

  tags = var.tags
}
