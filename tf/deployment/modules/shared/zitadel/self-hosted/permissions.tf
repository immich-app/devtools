locals {
  project_to_displaynames = flatten([
    for project in local.projects : [
      for role in project.roles : {
        project_name = project.name
        role_key     = role.key
      }
    ]
  ])

  # For each user+project, grant only the highest-priority role (first match in the ordered list)
  project_user_grants = flatten([
    for project in local.projects : [
      for user in local.users_data : {
        project_name   = project.name
        role_key       = [for role in project.roles : role.key if length(setintersection(toset(role.grants_to), toset(user.roles))) > 0][0]
        github_user_id = user.github.id
      }
      if length([for role in project.roles : role.key if length(setintersection(toset(role.grants_to), toset(user.roles))) > 0]) > 0
      && try(user.github.username, "") != ""
    ]
  ])
}


resource "zitadel_project_role" "project_roles" {
  for_each = {
    for project in local.project_to_displaynames : "${project.project_name}_${project.role_key}" => project
  }

  org_id       = zitadel_org.immich.id
  project_id   = zitadel_project.projects[each.value.project_name].id
  role_key     = each.value.role_key
  display_name = each.value.role_key
}

resource "zitadel_user_grant" "project_grants" {
  for_each = {
    for grant in local.project_user_grants : "${grant.project_name}_${grant.github_user_id}" => grant
  }
  depends_on = [zitadel_project_role.project_roles]

  org_id     = zitadel_org.immich.id
  project_id = zitadel_project.projects[each.value.project_name].id
  user_id    = zitadel_human_user.users[each.value.github_user_id].id
  role_keys  = [each.value.role_key]
}
