// Dedicated machine user for the zitadel-actions Cloudflare Worker, which calls
// the management API to sync IdP profile data (email + name) onto users during
// login. Least-privilege: ORG_USER_MANAGER is sufficient for UpdateHumanUser.
resource "zitadel_machine_user" "zitadel_actions" {
  org_id      = zitadel_org.immich.id
  user_name   = "zitadel-actions"
  name        = "ZITADEL Actions Worker"
  description = "Service account for the zitadel-actions CF worker (IdP profile sync)"
}

resource "zitadel_personal_access_token" "zitadel_actions" {
  org_id          = zitadel_org.immich.id
  user_id         = zitadel_machine_user.zitadel_actions.id
  expiration_date = "2030-01-01T00:00:00Z"
}

resource "zitadel_org_member" "zitadel_actions" {
  org_id  = zitadel_org.immich.id
  user_id = zitadel_machine_user.zitadel_actions.id
  roles   = ["ORG_USER_MANAGER"]
}

resource "onepassword_item" "zitadel_actions_pat" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "ZITADEL_ACTIONS_WORKER_PAT"
  category = "password"
  password = zitadel_personal_access_token.zitadel_actions.token
}
