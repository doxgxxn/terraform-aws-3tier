variable "name" {
  description = "Name prefix for all network resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "At least 2 AZs are required for high availability."
  }
}

variable "enable_nat" {
  description = "Create NAT gateway(s) for private subnet egress. Disable in dev to save ~USD 32/month."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all AZs (cheaper, less resilient). Only relevant when enable_nat is true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
