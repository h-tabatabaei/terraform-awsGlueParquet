resource "aws_transfer_server" "sftp_srv" {
  tags = {
    Name      = var.server_name
    Region    = var.Region
    Terraform = "true"
  }
}

resource "aws_transfer_user" "transfer_user" {
  server_id = aws_transfer_server.sftp_srv.id
  user_name = var.user_name
  role      = var.IAM_Role_arn

  home_directory = "/${var.sftp_bucket_id}"
}

resource "aws_transfer_ssh_key" "transfer_user_public_key" {
  server_id = aws_transfer_server.sftp_srv.id
  user_name = aws_transfer_user.transfer_user.user_name
  body      = var.transfer_public_key
}
