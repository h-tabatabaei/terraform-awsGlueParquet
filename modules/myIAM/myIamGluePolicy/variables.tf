variable "IAM_policy_name_source" {}
variable "IAM_policy_desc_source" {}
variable "source_Bucket_name" {}
variable "glue_policy_depends_on" { type = any }

variable "IAM_policy_name_dest" {}
variable "IAM_policy_desc_dest" {}
variable "dest_Bucket_name" {}


variable "IAM_Glue_role_name" {}
variable "IAM_Glue_role_service" {}

variable "Region" {}
