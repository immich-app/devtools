variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "futo_op_service_account_token" {
  sensitive = true
}

variable "futo_immich_op_connect_url" {
  description = "URL of immich's Connect server in the FUTO account"
}

variable "futo_immich_op_connect_token" {
  description = "Connect token with write access to the immich_* vaults in the FUTO account (1PASS_CONNECT_IMMICH_WRITE)"
  sensitive   = true
}
