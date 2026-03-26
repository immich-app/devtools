variable "tf_state_postgres_conn_str" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "zitadel_profile_json" {}
variable "futo_zitadel_profile_json" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}

variable "futo_internal_zitadel_github_client_id" {}
variable "futo_internal_zitadel_github_client_secret" {
  sensitive = true
}
