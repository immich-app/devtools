locals {
  users_data = jsondecode(file(var.users_data_file_path))

  github_users = {
    for user in local.users_data : user.github.username => user
    if user.github != null && user.github.username != null && user.github.username != ""
  }

  collaborators = {
    for user in local.github_users : user.github.username => (
      user.role == "contributor" ? "maintain" :
      (user.role == "support" ? "triage" : null)
    )
    if user.role == "contributor" || user.role == "support"
  }

  bots = {
    "weblate" = "write"
  }
}

resource "github_team" "employees" {
  name    = "Employees"
  privacy = "closed"
}

resource "github_team" "leadership" {
  name           = "Leadership"
  parent_team_id = github_team.employees.id
  privacy        = "closed"
}

resource "github_team" "team" {
  name           = "Team"
  parent_team_id = github_team.employees.id
  privacy        = "closed"
}

resource "github_team_members" "team" {
  team_id = github_team.team.id
  dynamic "members" {
    for_each = {
      for user in local.github_users : user.github.username => user
      if user.role == "team"
    }
    content {
      username = members.value.github.username
      role     = members.value.role == "admin" ? "maintainer" : "member"
    }
  }
}

resource "github_team_members" "leadership" {
  team_id = github_team.leadership.id
  dynamic "members" {
    for_each = {
      for user in local.github_users : user.github.username => user
      if user.role == "admin"
    }
    content {
      username = members.value.github.username
      role     = members.value.role == "admin" ? "maintainer" : "member"
    }
  }
}

resource "github_membership" "org_members" {
  for_each = {
    for user in local.github_users : user.github.username => user
    if user.role == "team" || user.role == "admin"
  }

  username = each.key
  role     = each.value.role == "admin" ? "admin" : "member"
}

resource "github_repository_collaborators" "repo_collaborators" {
  for_each = {
    for repo in var.repositories : repo.name => repo
    if coalesce(repo.collaborators, false)
  }

  repository = each.value.name

  dynamic "user" {
    // Modified: Only add general collaborators if repo.collaborators is true for the current repo
    for_each = coalesce(each.value.collaborators, false) ? local.collaborators : {}
    content {
      username   = user.key
      permission = user.value
    }
  }

  // Adds bot users to Immich repository only
  dynamic "user" {
    for_each = each.value.name == "immich" ? local.bots : {}
    content {
      username   = user.key
      permission = user.value
    }
  }

  lifecycle {
    ignore_changes = [
      team
    ]
  }
}
