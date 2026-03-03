locals {
  project_to_displaynames = flatten([
    for project in local.projects : [
      for role in keys(project.roles) : {
        project_name = project.name
        role_key     = role
      }
    ]
  ])

  project_to_zitadel_role_to_immich_role = flatten([
    for project in local.projects : [
      for zitadel_role, immich_roles in project.roles : [
        [for user in local.users_data : {
          project_name   = project.name
          role_key       = zitadel_role
          github_user_id = user.github.id
        } if contains(immich_roles, user.role) && user.github.username != null && user.github.username != ""]
      ]
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
    for user_role in local.project_to_zitadel_role_to_immich_role : "${user_role.project_name}_${user_role.role_key}_${user_role.github_user_id}" => user_role
  }
  depends_on = [zitadel_project_role.project_roles]

  org_id     = zitadel_org.immich.id
  project_id = zitadel_project.projects[each.value.project_name].id
  user_id    = zitadel_human_user.users[each.value.github_user_id].id
  role_keys  = [each.value.role_key]
}
