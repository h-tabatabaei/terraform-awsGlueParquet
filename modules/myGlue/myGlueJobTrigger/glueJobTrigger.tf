resource "aws_glue_trigger" "run_etl" {
  name = "run_${var.trigger_etl_job_name}"
  type = "ON_DEMAND"

  actions {
    job_name = var.trigger_etl_job_name
  }
  depends_on = [var.trigger_deponds_on_1, var.trigger_deponds_on_2]
}

// Note: best practice is using Scheduled trigger. I used it in my Production ENV.
/*resource "aws_glue_trigger" "run_etl" {
  name     = "run_${var.trigger_etl_job_name}"
  schedule = "cron(15 12 * * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = var.trigger_etl_job_name
  }
}*/