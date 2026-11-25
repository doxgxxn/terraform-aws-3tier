variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "github_repo" {
  description = "GitHub repository (owner/name) allowed to assume the CI role via OIDC"
  type        = string
  default     = "doxgxxn/terraform-aws-3tier"
}
