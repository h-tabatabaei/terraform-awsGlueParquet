output "IAM_role_arn" {
  value = aws_iam_role.service_to_s3_iamRole.arn
}

output "IAM_role_name" {
  value = aws_iam_role.service_to_s3_iamRole.name
}