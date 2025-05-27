variable "tf_state_postgres_conn_str" {}

variable "op_service_account_token" {}

variable "discord_token" {}

variable "discord_server_id" {}

variable "env" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}
