provider "discord" {
  token = var.discord_token
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
