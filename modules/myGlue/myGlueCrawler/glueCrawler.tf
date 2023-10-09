resource "aws_glue_crawler" "parquet_crawler" {
  database_name = var.database_name_crawler
  name          = var.crawler_name
  role          = var.IAM_Glue_role_arn_crawler

  s3_target {
    path = "s3://${var.glue_bucket_crawler}"
  }
}