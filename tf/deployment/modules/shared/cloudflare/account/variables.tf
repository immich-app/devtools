variable "cloudflare_account_id" {}
variable "cloudflare_api_token" {}
variable "tf_state_postgres_conn_str" {}
variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}
