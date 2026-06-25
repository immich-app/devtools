# NetBird groups and access policies are managed here.
#
# Nothing is defined yet, so a plan against a fresh module is a no-op. Add real
# resources below as the NetBird Cloud account is brought under IaC management.
# See https://registry.terraform.io/providers/netbirdio/netbird/latest/docs.
#
# Example — a group plus an access policy that allows traffic within it:
#
# resource "netbird_group" "team" {
#   name = "Team"
# }
#
# resource "netbird_policy" "team_access" {
#   name    = "Team Access"
#   enabled = true
#
#   rule {
#     name          = "Team Access"
#     action        = "accept"
#     bidirectional = true
#     enabled       = true
#     protocol      = "all"
#     sources       = [netbird_group.team.id]
#     destinations  = [netbird_group.team.id]
#   }
# }
