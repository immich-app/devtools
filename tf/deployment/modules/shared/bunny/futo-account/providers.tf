provider "bunnynet" {
  api_key = data.onepassword_item.bunny_api_key.password
}

provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}
