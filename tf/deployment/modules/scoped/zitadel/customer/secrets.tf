resource "onepassword_item" "application_client_id" {
  for_each = { for application in zitadel_application_oidc.applications : application.name => application }

  vault    = data.onepassword_vault.tf_env.uuid
  title    = "CUSTOMER_ZITADEL_OAUTH_CLIENT_ID_${each.value.name}"
  category = "password"

  password = each.value.client_id
}

resource "onepassword_item" "application_client_secret" {
  for_each = {
    for application in zitadel_application_oidc.applications : application.name => application
    if application.auth_method_type != "OIDC_AUTH_METHOD_TYPE_NONE"
  }

  vault    = data.onepassword_vault.tf_env.uuid
  title    = "CUSTOMER_ZITADEL_OAUTH_CLIENT_SECRET_${each.value.name}"
  category = "password"

  password = each.value.client_secret
}
