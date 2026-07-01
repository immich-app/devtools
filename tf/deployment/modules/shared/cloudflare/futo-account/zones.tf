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

# Reverse-DNS (PTR) zones for the 69.48.224.0/22 range we own: 69.48.224.0/24
# through 69.48.227.0/24. Already present in the FUTO Cloudflare account, so each
# is brought in via an import block. Deliberately NOT added to local.zones — the
# HTTP/TLS zone settings and tiered cache fanned out over that map (http3, ssl,
# rocket_loader, …) are meaningless for reverse-DNS zones. The PTR records live in
# dns-reverse.tf.
resource "cloudflare_zone" "reverse_69_48_224" {
  account = { id = local.cloudflare_account_id }
  name    = "224.48.69.in-addr.arpa"
  type    = "full"
}

import {
  to = cloudflare_zone.reverse_69_48_224
  id = "189e491aec974c2a87d1bcc378475f41"
}

resource "cloudflare_zone" "reverse_69_48_225" {
  account = { id = local.cloudflare_account_id }
  name    = "225.48.69.in-addr.arpa"
  type    = "full"
}

import {
  to = cloudflare_zone.reverse_69_48_225
  id = "2198b38e98f27f5cd4aa744f88f2e98e"
}

resource "cloudflare_zone" "reverse_69_48_226" {
  account = { id = local.cloudflare_account_id }
  name    = "226.48.69.in-addr.arpa"
  type    = "full"
}

import {
  to = cloudflare_zone.reverse_69_48_226
  id = "52fb8d9ee1e6d4453fef836e6f77cace"
}

resource "cloudflare_zone" "reverse_69_48_227" {
  account = { id = local.cloudflare_account_id }
  name    = "227.48.69.in-addr.arpa"
  type    = "full"
}

import {
  to = cloudflare_zone.reverse_69_48_227
  id = "9e63a9c563bab55d0e8415995cb2df4a"
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
