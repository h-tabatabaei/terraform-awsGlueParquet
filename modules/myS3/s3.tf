

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "sftp_bucket" {
  bucket = var.Name
  tags = {
    Name      = var.Name
    Region    = var.Region
    Terraform = "true"
  }
  depends_on = [var.source_s3_depends_on]
}
