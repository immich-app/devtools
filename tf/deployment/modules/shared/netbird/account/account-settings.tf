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
  peer_approval_enabled = true
}
