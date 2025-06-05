resource "zitadel_idp_github" "github" {
  name                = "GitHub"
  client_id           = var.zitadel_github_client_id
  client_secret       = var.zitadel_github_client_secret
  scopes              = ["read:user", "user:email"]
  is_auto_creation    = false
  is_auto_update      = true
  is_creation_allowed = false
  is_linking_allowed  = true
  auto_linking        = "AUTO_LINKING_OPTION_USERNAME"
}
