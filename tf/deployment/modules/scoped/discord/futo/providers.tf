provider "discord" {
  token = var.futo_discord_token
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
