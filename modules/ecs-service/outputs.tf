output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "task_security_group_id" {
  description = "Security group ID of the ECS tasks (grant this access to the db tier)"
  value       = aws_security_group.tasks.id
}

output "log_group_name" {
  description = "CloudWatch log group for the app container"
  value       = aws_cloudwatch_log_group.app.name
}
