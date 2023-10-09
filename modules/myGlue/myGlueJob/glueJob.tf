resource "terraform_data" "prepare_python_script" {
  provisioner "local-exec" {
    command = "sed -e 's/SOURCE_PATH/${var.source_bucket}/g;s/TARGET_PATH/${var.destination_bucket}/g'  ./CsvToParquetConvertor.py.temp > ./CsvToParquetConvertor.py"
  }
}

resource "terraform_data" "cp_py_to_target_bucket" {
  provisioner "local-exec" {
    command = "aws s3 cp ./CsvToParquetConvertor.py  s3://${var.destination_bucket}/"
  }
  depends_on = [terraform_data.prepare_python_script]
}

resource "aws_glue_job" "convert_parquet" {
  name              = var.etl_job_name
  role_arn          = var.iam_role_arn
  glue_version      = "4.0"
  number_of_workers = var.worker_count
  worker_type       = var.worker_type

  command {
    script_location = "s3://${var.destination_bucket}/CsvToParquetConvertor.py"
  }
}