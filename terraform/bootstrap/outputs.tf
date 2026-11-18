output "state_bucket_name" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "aws_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}



output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions using OIDC"
  value       = aws_iam_role.terraform_automation.arn
}



