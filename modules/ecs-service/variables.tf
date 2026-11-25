variable "name" {
  description = "Name prefix for ECS resources (also used as service/cluster name)"
  type        = string
}

variable "vpc_id" {
  description = "VPC the service runs in"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the ECS tasks (private app subnets; public in NAT-less dev)"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IPs to tasks. Only for NAT-less dev so tasks can pull images from public registries."
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "Security group of the ALB allowed to reach the tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group the service registers tasks into"
  type        = string
}

variable "container_image" {
  description = "Container image for the app task"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Baseline number of tasks"
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Autoscaling lower bound"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Autoscaling upper bound"
  type        = number
  default     = 2
}

variable "cpu_target_value" {
  description = "Average CPU utilization (%) the autoscaler maintains"
  type        = number
  default     = 60
}

variable "environment" {
  description = "Plain environment variables injected into the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret environment variables resolved at runtime from SSM/Secrets Manager (name -> valueFrom ARN)"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention for the app log group"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
