resource "github_actions_organization_secret" "cloudflare_api_token_pages_upload" {
  secret_name     = "CLOUDFLARE_API_TOKEN_PAGES_UPLOAD"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_pages_upload
  visibility      = "all"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_id" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_ID"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_id
  visibility      = "all"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_value" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_VALUE"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_value
  visibility      = "all"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_hashed_value" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_HASHED_VALUE"
  plaintext_value = sha256(data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_value)
  visibility      = "all"
}

