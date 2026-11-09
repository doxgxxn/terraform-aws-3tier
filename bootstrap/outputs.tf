output "tf_state_bucket" {
  description = "Set this as the repository variable TF_STATE_BUCKET"
  value       = aws_s3_bucket.tfstate.id
}

output "ci_role_arn" {
  description = "Set this as the repository variable AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}
