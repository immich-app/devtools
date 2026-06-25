# NetBird account-wide defaults.
#
# netbird_account_settings is a singleton covering the entire account's settings.
# Review the `tofu plan` diff before merging: any field not pinned here may move
# to the provider's default value. Pin more fields below as we decide on them.
resource "netbird_account_settings" "default" {
  # Require an admin to approve new users before they gain access. Users are
  # matched to the account via the SSO email domain and held in a pending state
  # until approved — ties directly into the Zitadel SSO integration.
  user_approval_required = true

  # Require an admin to approve each newly registered device/peer before it can
  # connect to the network (NetBird Cloud only).
  peer_approval_enabled = false

  # Derive NetBird group membership from the Zitadel SSO token. The zitadel-actions
  # worker flattens the user's NetBird-project roles into a `groups` string array
  # (gated to the NetBird project); NetBird auto-creates those groups and assigns
  # the user. groups_propagation pushes them onto the user's peers so network
  # policies can target them.
  jwt_groups_enabled         = true
  jwt_groups_claim_name      = "groups"
  groups_propagation_enabled = true

  # Custom address range NetBird assigns peer IPs from.
  network_range = "10.254.0.0/15"

  # Custom DNS domain peers are addressable under (e.g. <peer>.futo.network).
  dns_domain = "futo.network"
}
