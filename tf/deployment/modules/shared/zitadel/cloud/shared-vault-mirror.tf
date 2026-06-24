// Mirror the zitadel OIDC client credentials into the FUTO account's shared_tf
// vault, in addition to the immich tf copy in project.tf. Same item titles and
// values — only the target 1Password account/vault differs (FUTO service
// account vs the immich Connect server).
data "onepassword_vault" "shared_tf" {
  provider = onepassword.futo
  name     = "shared_tf"
}

resource "onepassword_item" "application_client_id_shared" {
  provider = onepassword.futo
  for_each = { for application in zitadel_application_oidc.applications : application.name => application }

  vault    = data.onepassword_vault.shared_tf.uuid
  title    = "FUTO_ZITADEL_OAUTH_CLIENT_ID_${each.value.name}"
  category = "password"

  password = each.value.client_id
}

resource "onepassword_item" "application_client_secret_shared" {
  provider = onepassword.futo
  for_each = {
    for application in zitadel_application_oidc.applications : application.name => application
    if application.auth_method_type != "OIDC_AUTH_METHOD_TYPE_NONE"
  }

  vault    = data.onepassword_vault.shared_tf.uuid
  title    = "FUTO_ZITADEL_OAUTH_CLIENT_SECRET_${each.value.name}"
  category = "password"

  password = each.value.client_secret
}
