variable "name" {
  description = "Name prefix for database resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC the database runs in"
  type        = string
}

variable "db_subnet_ids" {
  description = "Private db-tier subnets (at least 2 AZs)"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group of the app tier allowed to connect to the database"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL major engine version"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class (db.t4g.micro is free-tier eligible)"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Storage in GiB (20 GiB is the free-tier ceiling)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "app"
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "app_admin"
}

variable "multi_az" {
  description = "Enable Multi-AZ standby (prod only; doubles instance cost)"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Automated backup retention in days"
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Protect the instance from accidental terraform destroy (enable in prod)"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy (dev/ephemeral only)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
