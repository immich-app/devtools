variable "tf_state_postgres_conn_str" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "grafana_url" {}
variable "grafana_token" {}

variable "env" {}
