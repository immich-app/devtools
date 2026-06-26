variable "tf_state_postgres_conn_str" {}

variable "futo_op_service_account_token" {
  description = "1Password service-account token for the FUTO account, used to read the NetBird PAT from the shared_tf vault"
  sensitive   = true
}

variable "users_data_file_path" {
  description = "Path to the JSON file containing user data (roles), mirrored into NetBird groups. Resolvable from the Terragrunt execution directory or absolute."
  type        = string
}
