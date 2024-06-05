locals {
  cloudflare_account_id = get_env("CLOUDFLARE_ACCOUNT_ID")
  cloudflare_api_token  = get_env("CLOUDFLARE_API_TOKEN")
}

inputs = {
  cloudflare_account_id      = local.cloudflare_account_id
  cloudflare_api_token       = local.cloudflare_api_token
}