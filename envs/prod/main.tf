# prod: availability-first layout.
#   - Tasks in private subnets behind a NAT gateway (single NAT to control
#     cost; switch single_nat_gateway=false for per-AZ NAT when budget allows).
#   - Multi-AZ RDS, 7-day backups, deletion protection, final snapshot.
#   - 2+ tasks across 2 AZs with CPU target-tracking autoscaling.

module "network" {
  source = "../../modules/network"

  name               = var.name
  vpc_cidr           = var.vpc_cidr
  az_count           = 2
  enable_nat         = true
  single_nat_gateway = true

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
  subnet_ids            = module.network.app_subnet_ids
  assign_public_ip      = false
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn

  container_image = var.container_image
  container_port  = var.container_port
  cpu             = 256
  memory          = 512
  desired_count   = var.desired_count
  min_count       = 2
  max_count       = 4

  environment = {
    APP_ENV = "prod"
    DB_HOST = module.rds.address
    DB_PORT = tostring(module.rds.port)
    DB_NAME = module.rds.db_name
    DB_USER = module.rds.username
  }

  secrets = {
    DB_PASSWORD = module.rds.password_ssm_parameter_arn
  }

  log_retention_days = 30
}

module "rds" {
  source = "../../modules/rds"

  name                  = var.name
  vpc_id                = module.network.vpc_id
  db_subnet_ids         = module.network.db_subnet_ids
  app_security_group_id = module.app.task_security_group_id

  instance_class        = "db.t4g.micro"
  multi_az              = true
  backup_retention_days = 7
  deletion_protection   = true
  skip_final_snapshot   = false
}
