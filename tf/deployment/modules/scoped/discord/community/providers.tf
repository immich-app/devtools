provider "discord" {
  token = var.discord_token
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}

provider "onepassword" {
  alias                 = "futo"
  service_account_token = var.futo_op_service_account_token
}
