output "ssh_public_key" {
  value = aws_key_pair.ssh_kp.public_key
}