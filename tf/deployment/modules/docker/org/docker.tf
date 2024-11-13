# Define local variables for customization
locals {
  namespace        = "immichapp"
  repo_names       = ["immich-server", "immich-machine-learning", "immich-cli"]
  org_name         = "immichapp"
  team_name        = "immich-admins"
  admin_team_users = ["zackpollard"]
}

# Create repository
resource "docker_hub_repository" "org_repo" {
  for_each    = toset(local.repo_names)
  namespace   = local.namespace
  name        = each.key
  description = each.key
}

# Create team
resource "docker_org_team" "admin_team" {
  org_name         = local.org_name
  team_name        = local.team_name
  team_description = "Admins"
}

# Team association
resource "docker_org_team_member" "team_membership" {
  for_each = toset(local.admin_team_users)

  org_name  = local.org_name
  team_name = docker_org_team.admin_team.team_name
  user_name = each.value
}

resource "docker_hub_repository_team_permission" "repo_permission" {
  for_each   = docker_hub_repository.org_repo
  repo_id    = each.value.id
  team_id    = docker_org_team.admin_team.id
  permission = "admin"
}

resource "docker_access_token" "read_token" {
  token_label = "tf-read-token"
  scopes      = ["repo:read"]
}

output "read_token" {
  value     = docker_access_token.read_token.token
  sensitive = true
}

resource "docker_access_token" "write_token" {
  token_label = "tf-write-token"
  scopes      = ["repo:write"]
}

output "write_token" {
  value     = docker_access_token.write_token.token
  sensitive = true
}
