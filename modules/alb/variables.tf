variable "name" {
  description = "Name prefix for ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the ALB in"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR, used to restrict ALB egress to in-VPC targets only"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB (at least 2 AZs)"
  type        = list(string)
}

variable "target_port" {
  description = "Port the target containers listen on"
  type        = number
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check"
  type        = string
  default     = "/"
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN. When set, an HTTPS :443 listener is created and :80 redirects to it."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
