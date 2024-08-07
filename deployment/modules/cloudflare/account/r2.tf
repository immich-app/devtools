resource "cloudflare_r2_bucket" "tf_state_database_backups" {
  account_id = var.cloudflare_account_id
  name       = "tf-state-database-backups"
  location   = "WEUR"
}

resource "cloudflare_r2_bucket" "static" {
  account_id = var.cloudflare_account_id
  name       = "static"
}

resource "terraform_data" "r2_static_custom_domain" {
  triggers_replace = [
    cloudflare_r2_bucket.static.id,
  ]

  input = {
    bucket     = cloudflare_r2_bucket.static.name
    token      = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_account
    account_id = var.cloudflare_account_id
    zone_id    = cloudflare_zone.immich_cloud.id
    zone_name  = cloudflare_zone.immich_cloud.zone
    fqdn       = "static.immich.cloud"
  }

  provisioner "local-exec" {
    on_failure = fail
    when       = create
    command    = <<-EOT
      curl -f -X POST \
        -H 'Authorization: Bearer ${self.input.token}' \
        -d '{"domain":"${self.input.fqdn}", "zoneId":"${self.input.zone_id}", "zoneName":"${self.input.zone_name}"}' \
        'https://api.cloudflare.com/client/v4/accounts/${var.cloudflare_account_id}/r2/buckets/${self.input.bucket}/custom_domains'

      curl -f -X PUT \
        -H 'Authorization: Bearer ${self.input.token}' \
        'https://api.cloudflare.com/client/v4/accounts/${var.cloudflare_account_id}/r2/buckets/${self.input.bucket}/policy?cname=${self.input.fqdn}&access=CnamesOnly'

      curl -f -X PUT \
        -H 'Authorization: Bearer ${self.input.token}' -H 'Content-Type: application/json' \
        'https://api.cloudflare.com/client/v4/accounts/${var.cloudflare_account_id}/r2/buckets/${self.input.bucket}/cors' \
        --data '{"rules":[{"allowed":{"origins":["*"],"methods":["GET"]}}]}'
    EOT
  }

  provisioner "local-exec" {
    on_failure = fail
    when       = destroy
    command    = <<-EOT
      curl -f -X DELETE \
        -H 'Authorization: Bearer ${self.input.token}' \
        'https://api.cloudflare.com/client/v4/accounts/${self.input.account_id}/r2/buckets/${self.input.bucket}/custom_domains/${self.input.fqdn}'

      curl -f -X PUT \
        -H 'Authorization: Bearer ${self.input.token}' \
        'https://api.cloudflare.com/client/v4/accounts/${self.input.account_id}/r2/buckets/${self.input.bucket}/policy?cname=&access=CnamesOnly'

      curl -f -X DELETE \
        -H 'Authorization: Bearer ${self.input.token}' \
        'https://api.cloudflare.com/client/v4/accounts/${self.input.account_id}/r2/buckets/${self.input.bucket}/cors'
    EOT
  }
}

resource "cloudflare_page_rule" "static_cache_all" {
  zone_id = cloudflare_zone.immich_cloud.id
  target  = "static.immich.cloud/*"
  actions {
    cache_level       = "cache_everything"
    browser_cache_ttl = 2678400 # 31 days
    edge_cache_ttl    = 2678400 # 31 days
  }
}
