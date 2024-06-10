resource "cloudflare_record" "immich_cloud_aaaa_root" {
  name    = "immich.cloud"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = "100::"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_app_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = "100::"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_cname_star_dot_root" {
  name    = "*.immich.cloud"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "mich.immich.cloud"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_a_mich" {
  name    = "mich"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = local.mich_ip
  zone_id = cloudflare_zone.immich_cloud.id
}
