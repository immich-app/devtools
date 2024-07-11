resource "github_actions_organization_secret" "cloudflare_api_token_pages_upload" {
  secret_name     = "CLOUDFLARE_API_TOKEN_PAGES_UPLOAD"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_pages_upload
  visibility      = "all"
}

data "onepassword_item" "futo_gitlab_token" {
  title = "FUTO_GITLAB_TOKEN"
  vault = data.onepassword_vault.opentofu_vault.name
}

resource "github_actions_organization_secret" "futo_gitlab_token" {
  secret_name             = "FUTO_GITLAB_TOKEN"
  plaintext_value         = data.onepassword_item.futo_gitlab_token.credential
  visibility              = "selected"
  selected_repository_ids = [github_repository.repositories["devtools"].repo_id]
}
