# terraform-awsGlueParquet
Terraform Infrastructure code to deploy DataLake and csv convertor and make a Data Catalog from parquet file.

## Usage

### Define AWS Infrastructure

`````sh
terraform init
terraform fmt -recursive
terraform plan
terraform apply
`````

This Code will make the following resources:
	1- two Bucket will be created. sftp Bucket will be used to store CSV files uploaded from Clients into Transfer Family service.
	   the Target Bucket is used to store parquet file which converted from CSV file using ETL Glue Job

	2- ssh key-pair for safety connection from clients to Transfer Family.

	3- create neccessory IAM Role for Glue and Transfer Serivces access to Buckets and related resources.

	4- create Glue Etl job for convert CSV file to Parquet format.

	5- create Glue Trigger to start the conversion.

	6- create Glue Crawler to make Data Catalog Database and Table. which will be used by Athena to query the Parquet files.

Note: I make use of AWS OpenData to copy sample CSV file to SFTP Source Bucket.


make use of the outputs to create connection via filezilla or any other sftp clients.
the outputs are:
	Transfer_srv_endpoint = "endpoint address which will be used as a hostname in sftp connection via ftp client app."
	Transfer_srv_username = "msdtbt"
	s3_bucket_id = "arn of defined s3 bucket as a backend storage for aws transfer family service."
	s3_target_bucket_id = "arn of defined s3 bucket as a backend storage for Parquet file as ETL job output."

### how to use
#### configure the filezilla as ftp client
create a new connection in filezilla:

	Protocol: SFTP File Transfer Protocol
	HOST: "Transfer_srv_endpoint"

	Login Type: Key File
	User: "Transfer_srv_username"
	Key File: "path to MyAWSKey.pem"

#### varify the glue job
	- from AWS Glue Navigation go to Etl job and Job Run Montoring
	- check the run status of "csv2parquet" job should be "SUCCEEDED"
Note: in the case of Faild job Rerun the job and wait until became SUCCEEDED.

#### run the Glue Crawler
	- from AWS Glue Navigation choose Crawlers under Data Catalog.
	- select the "myParquetCrawler" and run the Crawler.
	- with until the "SUCCEEDED" appears under last_run Column.

#### run AWS Athena
