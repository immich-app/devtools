resource "cloudflare_zone" "futo_cloud" {
  account = { id = local.cloudflare_account_id }
  name    = "futo.cloud"
  type    = "full"
}

import {
  to = cloudflare_zone.futo_cloud
  id = "474fbfd96bf49879054a493f126c4071"
}

resource "cloudflare_zone" "futo_network" {
  account = { id = local.cloudflare_account_id }
  name    = "futo.network"
  type    = "full"
}

resource "cloudflare_zone" "as402421_net" {
  account = { id = local.cloudflare_account_id }
  name    = "as402421.net"
  type    = "full"
}

locals {
  zones = {
    futo_cloud   = cloudflare_zone.futo_cloud.id
    futo_network = cloudflare_zone.futo_network.id
    as402421_net = cloudflare_zone.as402421_net.id
  }

  zone_settings = {
    http3            = "on"
    "0rtt"           = "on"
    tls_1_3          = "zrt"
    always_use_https = "on"
    ssl              = "strict"
    brotli           = "on"
    early_hints      = "on"
    rocket_loader    = "on"
  }

  zone_setting_pairs = merge([
    for zone_key, zone_id in local.zones : {
      for setting_id, value in local.zone_settings :
      "${zone_key}:${setting_id}" => {
        zone_id    = zone_id
        setting_id = setting_id
        value      = value
      }
    }
  ]...)
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.zone_setting_pairs

  zone_id    = each.value.zone_id
  setting_id = each.value.setting_id
  value      = each.value.value
}

resource "cloudflare_tiered_cache" "this" {
  for_each = local.zones

  zone_id = each.value
  value   = "on"
}

output "futo_cloud_zone_id" {
  value = cloudflare_zone.futo_cloud.id
}

output "futo_network_zone_id" {
  value = cloudflare_zone.futo_network.id
}

output "as402421_net_zone_id" {
  value = cloudflare_zone.as402421_net.id
}
