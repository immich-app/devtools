locals {
  users_data = jsondecode(file(var.users_data_file_path))
}

resource "random_password" "zitadel_user_initial_password" {
  for_each = {
    for user in local.users_data : user.github.id => user
    if user.github.username != null && user.github.username != ""
  }
  length  = 64
  special = true
}

resource "zitadel_human_user" "users" {
  for_each = {
    for user in local.users_data : user.github.id => user
    if user.github.username != null && user.github.username != ""
  }
  email                        = "${each.value.github.id}+${each.value.github.username}@users.noreply.github.com"
  first_name                   = each.value.github.username
  last_name                    = "last_name"
  user_name                    = each.value.github.username
  org_id                       = zitadel_org.immich.id
  initial_password             = random_password.zitadel_user_initial_password[each.key].result
  initial_skip_password_change = true
  is_email_verified            = true
  is_phone_verified            = false

  lifecycle {
    ignore_changes = [
      first_name,
      last_name,
      email,
      nickname
    ]
  }
}

resource "zitadel_user_metadata" "role" {
  for_each = {
    for user in local.users_data : user.github.id => user
    if user.github.username != null && user.github.username != ""
  }
  org_id  = zitadel_org.immich.id
  user_id = zitadel_human_user.users[each.key].id
  key     = "role"
  value   = each.value.role
}
