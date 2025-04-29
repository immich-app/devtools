provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
