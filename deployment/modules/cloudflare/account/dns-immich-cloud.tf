resource "cloudflare_record" "immich_cloud_cname_root" {
  name    = "immich.cloud"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "mich.immich.cloud"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_cname_star_dot_root" {
  name    = "*.immich.cloud"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "immich.cloud"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_a_mich" {
  name    = "mich"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "162.55.86.82"
  zone_id = cloudflare_zone.immich_cloud.id
}
