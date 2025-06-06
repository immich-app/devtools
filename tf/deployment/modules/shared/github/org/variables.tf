variable "tf_state_postgres_conn_str" {}

variable "github_app_id" {}
variable "github_app_installation_id" {}
variable "github_app_pem_file" {}
variable "github_owner" {}

variable "op_service_account_token" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}
