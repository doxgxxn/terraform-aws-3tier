# dev: cost-minimized layout.
#   - No NAT gateway (~USD 32/month saved): tasks run in public subnets with
#     public IPs so they can pull images; ingress is still ALB-only via SG.
#   - Single-AZ free-tier RDS (db.t4g.micro, 20 GiB), no final snapshot.
#   - Designed to be ephemeral: apply -> verify -> destroy.

module "network" {
  source = "../../modules/network"

  name       = var.name
  vpc_cidr   = var.vpc_cidr
  az_count   = 2
  enable_nat = false

  tags = {}
}

module "alb" {
  source = "../../modules/alb"

  name              = var.name
  vpc_id            = module.network.vpc_id
  vpc_cidr          = module.network.vpc_cidr
  public_subnet_ids = module.network.public_subnet_ids
  target_port       = var.container_port
  health_check_path = "/"
  certificate_arn   = var.certificate_arn
}

module "app" {
  source = "../../modules/ecs-service"

  name                  = var.name
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.public_subnet_ids # NAT-less dev: see header comment
  assign_public_ip      = true
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn

  container_image = var.container_image
  container_port  = var.container_port
  cpu             = 256
  memory          = 512
  desired_count   = var.desired_count
  min_count       = 1
  max_count       = 2

  environment = {
    APP_ENV = "dev"
    DB_HOST = module.rds.address
    DB_PORT = tostring(module.rds.port)
    DB_NAME = module.rds.db_name
    DB_USER = module.rds.username
  }

  secrets = {
    DB_PASSWORD = module.rds.password_ssm_parameter_arn
  }

  log_retention_days = 7
}

module "rds" {
  source = "../../modules/rds"

  name                  = var.name
  vpc_id                = module.network.vpc_id
  db_subnet_ids         = module.network.db_subnet_ids
  app_security_group_id = module.app.task_security_group_id

  instance_class        = "db.t4g.micro"
  multi_az              = false
  backup_retention_days = 7 # backup storage is free up to the allocated storage size
  deletion_protection   = false
  skip_final_snapshot   = true
}
