variable "tf_state_postgres_conn_str" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "discord_token" {}

variable "futo_op_service_account_token" {
  description = "1Password service-account token for the FUTO account, used to write the webhook URLs into the yucca/o11y vaults"
  sensitive   = true
}

variable "discord_server_id" {}

variable "env" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}
