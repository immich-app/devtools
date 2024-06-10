resource "cloudflare_zone" "immich_app" {
  account_id = var.cloudflare_account_id
  zone       = "immich.app"
}

resource "cloudflare_zone_settings_override" "immich_app" {
  zone_id = cloudflare_zone.immich_app.id

  settings {
    http3            = "on"
    zero_rtt         = "on"
    tls_1_3          = "zrt"
    always_use_https = "on"
  }
}

output "immich_app_zone_id" {
  value = cloudflare_zone.immich_app.id
}

resource "cloudflare_zone" "immich_cloud" {
  account_id = var.cloudflare_account_id
  zone       = "immich.cloud"
}

resource "cloudflare_zone_settings_override" "immich_cloud" {
  zone_id = cloudflare_zone.immich_cloud.id

  settings {
    http3            = "on"
    zero_rtt         = "on"
    tls_1_3          = "zrt"
    always_use_https = "on"
  }
}

output "immich_cloud_zone_id" {
  value = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_zone" "immich_futo_org" {
  account_id = var.cloudflare_account_id
  zone       = "immich.futo.org"
}

resource "cloudflare_zone_settings_override" "immich_futo_org" {
  zone_id = cloudflare_zone.immich_futo_org.id

  settings {
    http3            = "on"
    zero_rtt         = "on"
    tls_1_3          = "zrt"
    always_use_https = "on"
  }
}

output "immich_futo_org_zone_id" {
  value = cloudflare_zone.immich_futo_org.id
}
