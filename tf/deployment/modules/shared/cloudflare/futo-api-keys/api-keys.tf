locals {
  token_permission_names = toset([
    "Zone Read",
    "Zone Write",
    "Zone Settings Write",
    "DNS Write",
  ])
}

data "cloudflare_account_api_token_permission_groups_list" "all" {
  account_id = local.account_id
}

locals {
  permission_group_ids_by_name = {
    for pg in data.cloudflare_account_api_token_permission_groups_list.all.result :
    pg.name => pg.id...
  }
  permission_group_ids = [
    for name in local.token_permission_names :
    local.permission_group_ids_by_name[name][0]
  ]
}

resource "cloudflare_account_token" "terraform_futo_cloudflare_account" {
  account_id = local.account_id
  name       = "terraform_futo_cloudflare_account"

  policies = [{
    effect            = "allow"
    permission_groups = [for id in local.permission_group_ids : { id = id }]
    resources = jsonencode({
      "com.cloudflare.api.account.${local.account_id}" = "*"
    })
  }]
}

output "terraform_key_futo_cloudflare_account" {
  value     = cloudflare_account_token.terraform_futo_cloudflare_account.value
  sensitive = true
}

# Dedicated token for the futo_bootstrap cluster's cert-manager DNS-01 solver.
# Permissions limited to Zone Read + DNS Write. Account-scoped (all account zones)
# rather than restricted to futo.network: that zone is created by the futo-account
# module, which consumes a token this module mints — so this bootstrap token must not
# reference it (a dependency, or a data source on its live state, would couple the
# two the wrong way and fail before futo-account has created the zone). cert-manager
# only ever writes _acme-challenge TXT records, so the broader resource scope is low-risk.
# (For a non-bootstrap, zone-restricted DNS token see futo_network_dns below.)
locals {
  cert_manager_permission_names = ["Zone Read", "DNS Write"]
  cert_manager_permission_group_ids = [
    for name in local.cert_manager_permission_names :
    local.permission_group_ids_by_name[name][0]
  ]
}

resource "cloudflare_account_token" "futo_bootstrap_cert_manager" {
  account_id = local.account_id
  name       = "futo_bootstrap_cert_manager"

  policies = [{
    effect            = "allow"
    permission_groups = [for id in local.cert_manager_permission_group_ids : { id = id }]
    resources = jsonencode({
      "com.cloudflare.api.account.${local.account_id}" = "*"
    })
  }]
}

output "futo_bootstrap_cert_manager_token" {
  value     = cloudflare_account_token.futo_bootstrap_cert_manager.value
  sensitive = true
}

# General-purpose DNS-edit token for the futo.network zone, distributed to the shared_tf
# vault for any project that needs to manage futo.network DNS records. Scoped to
# Zone Read + DNS Write on the futo.network zone ONLY — the tightest scope Cloudflare
# offers for DNS management (Zone Read is required so consumers can resolve the zone).
#
# NOTE: unlike futo_bootstrap_cert_manager above, this token is restricted to a single
# zone and therefore references data.cloudflare_zone.futo_network (data.tf). That zone is
# created by the futo-account module, which consumes a token minted here — so this token
# is NOT part of a clean bootstrap: it can only plan/apply once futo.network exists. The
# account-scoped futo_bootstrap_cert_manager token remains the bootstrap-safe path.
locals {
  futo_network_dns_permission_names = ["Zone Read", "DNS Write"]
  futo_network_dns_permission_group_ids = [
    for name in local.futo_network_dns_permission_names :
    local.permission_group_ids_by_name[name][0]
  ]
}

resource "cloudflare_account_token" "futo_network_dns" {
  account_id = local.account_id
  name       = "futo_network_dns"

  policies = [{
    effect            = "allow"
    permission_groups = [for id in local.futo_network_dns_permission_group_ids : { id = id }]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.futo_network.id}" = "*"
    })
  }]
}

output "futo_network_dns_token" {
  value     = cloudflare_account_token.futo_network_dns.value
  sensitive = true
}
