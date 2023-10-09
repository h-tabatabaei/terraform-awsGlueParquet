output "bucket_id" {
  value = aws_s3_bucket.sftp_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.sftp_bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.sftp_bucket.bucket
}