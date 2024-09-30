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
    ssl              = "strict"
    brotli           = "on"
    fonts            = "on"
    early_hints      = "on"
    rocket_loader    = "on"
    speed_brain      = "on"
  }
}

resource "cloudflare_tiered_cache" "immich_app" {
  zone_id    = cloudflare_zone.immich_app.id
  cache_type = "smart"
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
    ssl              = "strict"
  }
}

resource "cloudflare_tiered_cache" "immich_cloud" {
  zone_id    = cloudflare_zone.immich_cloud.id
  cache_type = "smart"
}

output "immich_cloud_zone_id" {
  value = cloudflare_zone.immich_cloud.id
}
