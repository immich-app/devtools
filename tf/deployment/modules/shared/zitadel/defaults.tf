resource "zitadel_default_login_policy" "default" {
  user_login                    = false
  allow_register                = false
  allow_external_idp            = true
  force_mfa                     = false
  force_mfa_local_only          = false
  passwordless_type             = "PASSWORDLESS_TYPE_NOT_ALLOWED"
  hide_password_reset           = "true"
  password_check_lifetime       = "240h0m0s"
  external_login_check_lifetime = "720h0m0s"
  multi_factor_check_lifetime   = "24h0m0s"
  mfa_init_skip_lifetime        = "720h0m0s"
  second_factor_check_lifetime  = "24h0m0s"
  ignore_unknown_usernames      = true
  default_redirect_uri          = ""
  second_factors                = []
  multi_factors                 = []
  idps                          = [zitadel_idp_github.github.id]
  allow_domain_discovery        = false
  disable_login_with_email      = true
  disable_login_with_phone      = true
}

resource "zitadel_default_oidc_settings" "default" {
  access_token_lifetime         = "12h0m0s"
  id_token_lifetime             = "12h0m0s"
  refresh_token_expiration      = "720h0m0s"
  refresh_token_idle_expiration = "2160h0m0s"
}

// Find the default zitadel project and disallow users from logging in
resource "zitadel_project" "zitadel" {
  name                     = "Zitadel"
  org_id                   = data.zitadel_orgs.zitadel.ids[0]
  project_role_assertion   = false
  project_role_check       = true
  has_project_check        = false
  private_labeling_setting = "PRIVATE_LABELING_SETTING_UNSPECIFIED"
}

resource "zitadel_instance_member" "superusers" {
  for_each = {
    for user in local.users_data : user.github.id => user
    if user.github.username != null && user.github.username != "" && user.role == "admin"
  }
  user_id = zitadel_human_user.users[each.key].id
  roles   = ["IAM_OWNER"]
}

resource "zitadel_project_role" "zitadel_admin" {
  org_id       = zitadel_project.zitadel.org_id
  project_id   = zitadel_project.zitadel.id
  role_key     = "admin"
  display_name = "Admin"
}

resource "zitadel_user_grant" "superusers" {
  for_each = {
    for user in local.users_data : user.github.id => user
    if user.github.username != null && user.github.username != "" && user.role == "admin"
  }
  org_id     = zitadel_project.zitadel.org_id
  project_id = zitadel_project.zitadel.id
  user_id    = zitadel_human_user.users[each.key].id
  role_keys  = [zitadel_project_role.zitadel_admin.role_key]
}

import {
  id = data.zitadel_projects.zitadel.project_ids[0]
  to = zitadel_project.zitadel
}
