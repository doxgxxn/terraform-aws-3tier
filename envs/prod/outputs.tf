output "app_url" {
  description = "Public URL of the app"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster" {
  description = "ECS cluster name"
  value       = module.app.cluster_name
}

output "rds_address" {
  description = "RDS endpoint address (resolvable only inside the VPC)"
  value       = module.rds.address
}
