variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "name" {
  description = "Name prefix for this environment"
  type        = string
  default     = "t3t-dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR for this environment"
  type        = string
  default     = "10.10.0.0/16"
}

variable "container_image" {
  description = "App container image"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable-alpine"
}

variable "container_port" {
  description = "Port the app container listens on"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Baseline number of app tasks"
  type        = number
  default     = 1
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS"
  type        = string
  default     = null
}
