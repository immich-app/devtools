resource "zitadel_idp_github" "github" {
  name                = "GitHub"
  client_id           = var.futo_internal_zitadel_github_client_id
  client_secret       = var.futo_internal_zitadel_github_client_secret
  scopes              = ["read:user", "user:email"]
  is_auto_creation    = false
  is_auto_update      = true
  is_creation_allowed = false
  is_linking_allowed  = true
  # Auto-linking disabled — every identity is linked explicitly by external id
  # via terraform_data.idp_link (idp-links.tf), so a login only matches a
  # pre-created link, never a username/email heuristic.
  auto_linking = "AUTO_LINKING_OPTION_UNSPECIFIED"
}

resource "zitadel_idp_gitlab_self_hosted" "gitlab" {
  name                = "FUTO GitLab"
  client_id           = var.zitadel_gitlab_client_id
  client_secret       = var.zitadel_gitlab_client_secret
  issuer              = var.zitadel_gitlab_issuer
  scopes              = ["openid", "profile", "email"]
  is_auto_creation    = false
  is_auto_update      = true
  is_creation_allowed = false
  is_linking_allowed  = true
  # Auto-linking disabled — every identity is linked explicitly by external id
  # via terraform_data.idp_link (idp-links.tf), so a login only matches a
  # pre-created link, never a username/email heuristic.
  auto_linking = "AUTO_LINKING_OPTION_UNSPECIFIED"
}
