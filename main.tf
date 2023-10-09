#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  sftp_bucket_name = "sftp-transfer-msd-${module.random.random_out}"
  glue_bucket_name = "glue-target-bucket-msd-${module.random.random_out}"
  sftp_user_name   = "msdtbt"
  glue_db_name     = "my_db_catalog"
  glue_tbl_name    = "parquet_tbl"
}

module "random" {
  source      = "./modules/myRandom"
  byte_length = 5
}
// create sftp s3 file holder which saved csv files 
module "source_s3" {
  source               = "./modules/myS3"
  source_s3_depends_on = module.random.random_out
  Name                 = local.sftp_bucket_name
  Region               = data.aws_region.current.name
}

//create IAM Policy and Role for accessing Transfer service to sftp S3 bucket
module "IAM_Sftp_Policy_Role" {
  source          = "./modules/myIAM/myIAMSftpPolicy"
  IAM_policy_name = "Transfer_to_S3_policy"
  IAM_policy_desc = "A policy to allow s3 access from Transfer for source bucket"
  Bucket_name     = local.sftp_bucket_name

  IAM_role_name          = "Transfer_to_s3_role"
  IAM_role_service       = "transfer.amazonaws.com"
  sftp_policy_depends_on = module.source_s3.bucket_name
  Region                 = data.aws_region.current.name
}

// create ssh key files for connection from sftp client into aws transfer
module "my_ssh_key" {
  source = "./modules/mySshKey"

  pem_filename = "MyAWSKey.pem"
  key_name     = "ssh_key"
}

// creating Transfer familly service 
module "my_aws_transfer" {
  source = "./modules/myTransferSrv"

  server_name = "sftp_server"
  Region      = data.aws_region.current.name

  user_name           = local.sftp_user_name
  IAM_Role_arn        = module.IAM_Sftp_Policy_Role.IAM_role_arn
  sftp_bucket_id      = module.source_s3.bucket_id
  transfer_public_key = module.my_ssh_key.ssh_public_key
}

// cp sample csf file from openData to source s3 bucket.
// in real life user will scp their file into that bucket.
resource "terraform_data" "copy_sample_csv" {
  provisioner "local-exec" {
    command = "aws s3 cp s3://nyc-tlc/csv_backup/yellow_tripdata_2020-05.csv  s3://${module.source_s3.bucket_name}/"
  }
}

module "target_s3" {
  source               = "./modules/myS3"
  source_s3_depends_on = module.random.random_out
  Name                 = local.glue_bucket_name
  Region               = data.aws_region.current.name
}

//create IAM Policy and Role for accessing Transfer service to sftp S3 bucket
module "IAM_Glue_Policy_Role" {
  source                 = "./modules/myIAM/myIamGluePolicy"
  IAM_policy_name_source = "Glue_to_source_S3_read_policy"
  IAM_policy_desc_source = "A policy to allow s3 read access from glue for source bucket"
  source_Bucket_name     = local.sftp_bucket_name

  IAM_policy_name_dest = "Glue_to_dest_S3_full_policy"
  IAM_policy_desc_dest = "A policy to allow s3 full access from glue for destination bucket"
  dest_Bucket_name     = local.glue_bucket_name

  IAM_Glue_role_name     = "glue_to_s3_role"
  IAM_Glue_role_service  = "glue.amazonaws.com"
  glue_policy_depends_on = module.target_s3.bucket_name

  Region = data.aws_region.current.name
}


module "glue_data_catalog" {
  source  = "./modules/myGlue/myGlueDataCatalog"
  db_name = local.glue_db_name
}
// in next resource definition I make a delay between Data Catalog DB and Table creation.
/*resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.glue_data_catalog]

  create_duration = "30s"
}*/

module "glue_parquet_convert" {
  source             = "./modules/myGlue/myGlueJob"
  source_bucket      = module.source_s3.bucket_name
  destination_bucket = module.target_s3.bucket_name
  etl_job_name       = "csv2parquet"
  iam_role_arn       = module.IAM_Glue_Policy_Role.IAM_role_arn
  worker_count       = 2
  worker_type        = "G.1X"
}

module "glue_job_trigger" {
  source               = "./modules/myGlue/myGlueJobTrigger"
  trigger_etl_job_name = "csv2parquet"
  trigger_deponds_on_1 = module.glue_parquet_convert.etl_job_id
  trigger_deponds_on_2 = module.IAM_Glue_Policy_Role.IAM_role_name
}

module "parquet_crawler" {
  source                    = "./modules/myGlue/myGlueCrawler"
  database_name_crawler     = module.glue_data_catalog.glue_db_catalog_id
  crawler_name              = "myParquetCrawler"
  IAM_Glue_role_arn_crawler = module.IAM_Glue_Policy_Role.IAM_role_arn
  glue_bucket_crawler       = module.target_s3.bucket_name
}
