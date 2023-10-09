variable "IAM_policy_name" {}
variable "IAM_policy_desc" {}
variable "Bucket_name" {}
variable "sftp_policy_depends_on" { type = any }

variable "IAM_role_name" {}
variable "IAM_role_service" {}

variable "Region" {}