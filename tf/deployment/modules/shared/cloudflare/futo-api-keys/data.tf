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

# futo.network zone, resolved by name so the DNS-edit token in api-keys.tf can be
# scoped to it. Unlike the account-scoped tokens in this module, this data source
# couples us to the zone already existing (it is created by the futo-account module,
# which itself consumes a token minted here) — see the note above the
# cloudflare_account_token.futo_network_dns resource.
data "cloudflare_zone" "futo_network" {
  filter = {
    name = "futo.network"
    account = {
      id = local.account_id
    }
  }
}
