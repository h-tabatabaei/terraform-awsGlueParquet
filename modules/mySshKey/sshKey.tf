resource "tls_private_key" "ssh_pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ssh_kp" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_pkey.public_key_openssh
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_pkey.private_key_pem
  filename = var.pem_filename
}

