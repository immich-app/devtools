variable "tf_state_postgres_conn_str" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "futo_discord_token" {}

variable "futo_discord_server_id" {}

variable "env" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}
