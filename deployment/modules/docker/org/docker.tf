# Define local variables for customization
locals {
  namespace        = "immichapp"
  repo_name        = "immich"
  org_name         = "immichapp"
  team_name        = "immich"
  my_team_users    = ["zackpollard", "altran1502"]
  token_label      = "test-token"
  token_scopes     = ["repo:read", "repo:write"]
  permission       = "admin"
}

# Create repository
resource "docker_hub_repository" "org_hub_repo" {
  namespace        = local.namespace
  name             = local.repo_name
  description      = "This is a generic Docker repository."
  full_description = "Full description for the repository."
}

# Create team
resource "docker_org_team" "team" {
  org_name         = local.org_name
  team_name        = local.team_name
  team_description = "Team description goes here."
}

# Team association
resource "docker_org_team_member" "team_membership" {
  for_each = toset(local.my_team_users)

  org_name  = local.org_name
  team_name = docker_org_team.team.team_name
  user_name = each.value
}

# Create repository team permission
resource "docker_hub_repository_team_permission" "repo_permission" {
  repo_id    = docker_hub_repository.org_hub_repo.id
  team_id    = docker_org_team.team.id
  permission = local.permission
}

# Create access token
resource "docker_access_token" "access_token" {
  token_label = local.token_label
  scopes      = local.token_scopes
}
