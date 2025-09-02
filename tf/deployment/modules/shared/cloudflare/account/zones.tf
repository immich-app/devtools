resource "cloudflare_zone" "immich_app" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "immich.app"
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
  zone_id = cloudflare_zone.immich_app.id
  value   = "smart"
}


output "immich_app_zone_id" {
  value = cloudflare_zone.immich_app.id
}

resource "cloudflare_zone" "immich_cloud" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "immich.cloud"
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
  zone_id = cloudflare_zone.immich_cloud.id
  value   = "smart"
}

output "immich_cloud_zone_id" {
  value = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_zone" "immich_store" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "immich.store"
}

resource "cloudflare_zone_settings_override" "immich_store" {
  zone_id = cloudflare_zone.immich_store.id

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

resource "cloudflare_tiered_cache" "immich_store" {
  zone_id = cloudflare_zone.immich_store.id
  value   = "smart"
}

import {
  to = cloudflare_zone.immich_store
  id = "480716ce895e047f0a428292e1ccbe98"
}


output "immich_store_zone_id" {
  value = cloudflare_zone.immich_store.id
}
