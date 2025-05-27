locals {
  users_data = jsondecode(file(var.users_data_file_path))

  collaborators = {
    for user in local.users_data : user.github.username => (
      user.role == "contributor" ? "maintain" :
      (user.role == "support" ? "triage" : null)
    )
    if user.github != null && user.github.username != null && user.github.username != "" &&
    (user.role == "contributor" || user.role == "support")
  }
}

resource "github_membership" "org_members" {
  for_each = {
    for user in local.users_data : user.github.username => user
    if user.role == "admin" || user.role == "team"
  }

  username = each.key
  role     = "admin"
}

resource "github_repository_collaborators" "repo_collaborators" {
  for_each = {
    for repo in var.repositories : repo.name => repo
    if coalesce(repo.collaborators, false) == true
  }

  repository = each.value.name

  dynamic "user" {
    for_each = local.collaborators
    content {
      username   = user.key
      permission = user.value
    }
  }
}
