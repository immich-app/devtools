locals {
  users_data = jsondecode(file(var.users_data_file_path))

  github_users = {
    for user in local.users_data : tostring(user.github.id) => user
    if try(user.github.username, "") != ""
  }

  gitlab_only_users = {
    for user in local.users_data : "gitlab-${user.gitlab.id}" => user
    if try(user.github.username, "") == "" && try(user.gitlab.username, "") != ""
  }

  zitadel_users = merge(local.github_users, local.gitlab_only_users)
}

resource "random_password" "zitadel_user_initial_password" {
  for_each = local.zitadel_users
  length   = 64
  special  = true
}

resource "zitadel_human_user" "users" {
  for_each = local.zitadel_users

  email = (
    try(each.value.github.username, "") != ""
    ? "${each.value.github.id}+${each.value.github.username}@users.noreply.github.com"
    : "${each.value.gitlab.username}@${replace(var.zitadel_gitlab_issuer, "https://", "")}"
  )
  first_name                   = try(each.value.github.username, "") != "" ? each.value.github.username : each.value.gitlab.username
  last_name                    = "last_name"
  user_name                    = try(each.value.github.username, "") != "" ? each.value.github.username : each.value.gitlab.username
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
      nick_name
    ]
  }
}

resource "zitadel_user_metadata" "role" {
  for_each = local.zitadel_users
  org_id   = zitadel_org.immich.id
  user_id  = zitadel_human_user.users[each.key].id
  key      = "role"
  value    = jsonencode(each.value.roles)
}
