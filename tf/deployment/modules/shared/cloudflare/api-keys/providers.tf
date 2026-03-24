provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
