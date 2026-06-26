# NetBird groups, mirrored from the maintainer roles in
# tf/deployment/data/users.json.
#
# Each distinct internal role (team, futo, immich, yucca, *_admin) becomes a
# NetBird group so access policies and Zitadel SSO group sync can target them.
# The community-facing contributor/support roles are intentionally excluded.
# Group membership is driven by SSO claims at login, not managed here — this
# only declares the groups themselves.
#
# Add access policies with netbird_policy, using netbird_group.role[<role>].id
# as sources/destinations. See
# https://registry.terraform.io/providers/netbirdio/netbird/latest/docs.
locals {
  users_data = jsondecode(file(var.users_data_file_path))

  # Community-facing roles that should not become NetBird groups.
  excluded_roles = ["contributor", "support"]

  # Distinct set of internal roles across all users.
  netbird_roles = toset([
    for role in flatten([for user in local.users_data : user.roles]) :
    role if !contains(local.excluded_roles, role)
  ])
}

resource "netbird_group" "role" {
  for_each = local.netbird_roles

  name = each.value
}
