locals {
  users_data = jsondecode(file(var.users_data_file_path))

  github_users = {
    for user in local.users_data : user.github.username => user
    if user.github != null && user.github.username != null && user.github.username != ""
  }

  collaborators = {
    for user in local.github_users : user.github.username => (
      length(setintersection(toset(user.roles), toset(["contributor", "futo"]))) > 0 ? "maintain" :
      (contains(user.roles, "support") ? "triage" : null)
    )
    if length(setintersection(toset(user.roles), toset(["contributor", "support", "futo"]))) > 0
    && try(user.active, true) != false
  }

  bots = {
    "weblate" = "push"
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
      if contains(user.roles, "team")
    }
    content {
      username = members.value.github.username
      role     = contains(members.value.roles, "admin") ? "maintainer" : "member"
    }
  }
}

resource "github_team_members" "leadership" {
  team_id = github_team.leadership.id
  dynamic "members" {
    for_each = {
      for user in local.github_users : user.github.username => user
      if contains(user.roles, "admin")
    }
    content {
      username = members.value.github.username
      role     = contains(members.value.roles, "admin") ? "maintainer" : "member"
    }
  }
}

resource "github_membership" "org_members" {
  for_each = {
    for user in local.github_users : user.github.username => user
    if length(setintersection(toset(user.roles), toset(["team", "yucca", "admin"]))) > 0
  }

  username = each.key
  role     = contains(each.value.roles, "admin") ? "admin" : "member"
}

resource "github_repository_collaborators" "repo_collaborators" {
  for_each = {
    for repo in var.repositories : repo.name => repo
  }

  repository = each.value.name

  dynamic "user" {
    // Modified: Only add general collaborators if repo.collaborators is true for the current repo
    for_each = merge(coalesce(each.value.collaborators, false) ? local.collaborators : {}, each.value.collaborator_overrides)
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
