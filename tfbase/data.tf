data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

output "aws_account_id" {
  value = local.aws_account_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_caller_user" {
  value = data.aws_caller_identity.current.user_id
}
