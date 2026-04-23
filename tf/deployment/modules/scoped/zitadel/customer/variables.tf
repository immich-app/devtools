variable "env" {}

variable "tf_state_postgres_conn_str" {}

variable "futo_op_service_account_token" {
  description = "1Password service-account token for the FUTO account, used to read/write secrets in the yucca_tf_<env> vaults."
  sensitive   = true
}
