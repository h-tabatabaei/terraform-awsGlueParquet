output "Transfer_endpoint" {
  value = aws_transfer_server.sftp_srv.endpoint
}
output "transfer_username" {
  value = aws_transfer_user.transfer_user.user_name
}

