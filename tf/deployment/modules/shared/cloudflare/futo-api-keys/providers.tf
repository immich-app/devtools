provider "cloudflare" {
  api_token = data.onepassword_item.cloudflare_api_token.password
}

provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}
