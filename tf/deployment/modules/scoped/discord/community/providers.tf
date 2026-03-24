provider "discord" {
  token = var.discord_token
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
