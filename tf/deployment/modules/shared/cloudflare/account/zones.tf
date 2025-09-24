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

resource "cloudflare_zone" "immich_store" {
  account_id = var.cloudflare_account_id
  zone       = "immich.store"
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
  zone_id    = cloudflare_zone.immich_store.id
  cache_type = "smart"
}

import {
  to = cloudflare_zone.immich_store
  id = "480716ce895e047f0a428292e1ccbe98"
}


output "immich_store_zone_id" {
  value = cloudflare_zone.immich_store.id
}

resource "cloudflare_zone" "immich_cc" {
  account_id = var.cloudflare_account_id
  zone       = "immich.cc"
}

resource "cloudflare_zone_settings_override" "immich_cc" {
  zone_id = cloudflare_zone.immich_cc.id

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

resource "cloudflare_tiered_cache" "immich_cc" {
  zone_id    = cloudflare_zone.immich_cc.id
  cache_type = "smart"
}


output "immich_cc_zone_id" {
  value = cloudflare_zone.immich_cc.id
}

resource "cloudflare_zone" "immich_pro" {
  account_id = var.cloudflare_account_id
  zone       = "immich.pro"
}

resource "cloudflare_zone_settings_override" "immich_pro" {
  zone_id = cloudflare_zone.immich_pro.id

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

resource "cloudflare_tiered_cache" "immich_pro" {
  zone_id    = cloudflare_zone.immich_pro.id
  cache_type = "smart"
}


output "immich_pro_zone_id" {
  value = cloudflare_zone.immich_pro.id
}
