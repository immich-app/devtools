data "onepassword_vault" "shared_tf" {
  name = "shared_tf"
}

data "onepassword_item" "cloudflare_api_token" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "CLOUDFLARE_API_TOKEN"
}

data "onepassword_item" "cloudflare_account_id" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "CLOUDFLARE_ACCOUNT_ID"
}

locals {
  account_id = data.onepassword_item.cloudflare_account_id.password
}

# futo.network zone ID, published into the shared_tf vault by the cloudflare/futo-account
# module as part of zone setup. Read from 1Password rather than via a data.cloudflare_zone
# lookup because the CLOUDFLARE_API_TOKEN this module runs as only has "Account API Tokens
# Write" (no Zone Read), so a zone data source returns 0 results.
#
# Gated by var.create_futo_network_dns_token: on a fresh account (or the initial rollout
# of this feature) futo-account has not published FUTO_NETWORK_ZONE_ID yet, and a missing
# item would hard-fail this whole module — including the bootstrap token that futo-account
# needs. Set the variable false for that first pass, then true once the ID is published.
data "onepassword_item" "futo_network_zone_id" {
  count = var.create_futo_network_dns_token ? 1 : 0
  vault = data.onepassword_vault.shared_tf.uuid
  title = "FUTO_NETWORK_ZONE_ID"
}
