output "s3_bucket_id" {
  description = "The ARN of the SFTP bucket."
  value       = module.source_s3.bucket_arn
}

output "s3_target_bucket_id" {
  description = "The ARN of the target bucket."
  value       = module.target_s3.bucket_arn
}

output "Transfer_srv_username" {
  description = "This is the transfer server UserName!"
  value       = module.my_aws_transfer.transfer_username
}


output "Transfer_srv_endpoint" {
  description = "This is the transfer server Endpoint!"
  value       = module.my_aws_transfer.Transfer_endpoint
}