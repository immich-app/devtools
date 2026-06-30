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
