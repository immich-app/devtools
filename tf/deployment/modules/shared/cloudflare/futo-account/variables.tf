variable "tf_state_postgres_conn_str" {}

variable "futo_op_service_account_token" {
  description = "1Password service-account token for the FUTO account, used to read the FUTO Cloudflare account ID from the shared_tf vault"
  sensitive   = true
}
