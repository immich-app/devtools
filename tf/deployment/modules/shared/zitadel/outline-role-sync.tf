resource "zitadel_machine_user" "outline_role_sync" {
  org_id      = zitadel_org.immich.id
  user_name   = "outline-role-sync"
  name        = "Outline Role Sync"
  description = "Service account for syncing Zitadel roles to Outline groups"
}

resource "zitadel_personal_access_token" "outline_role_sync" {
  org_id          = zitadel_org.immich.id
  user_id         = zitadel_machine_user.outline_role_sync.id
  expiration_date = "2030-01-01T00:00:00Z"
}

resource "zitadel_org_member" "outline_role_sync" {
  org_id  = zitadel_org.immich.id
  user_id = zitadel_machine_user.outline_role_sync.id
  roles   = ["ORG_USER_MANAGER"]
}

resource "onepassword_item" "outline_role_sync_zitadel_token" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "OUTLINE_ROLE_SYNC_ZITADEL_TOKEN"
  category = "password"
  password = zitadel_personal_access_token.outline_role_sync.token
}

resource "onepassword_item" "outline_role_sync_zitadel_project_id" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "OUTLINE_ROLE_SYNC_ZITADEL_PROJECT_ID"
  category = "password"
  password = zitadel_project.projects["Outline"].id
}
