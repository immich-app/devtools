resource "cloudflare_record" "immich_pro_aaaa_root" {
  name    = "immich.pro"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_pro.id
}

resource "cloudflare_record" "immich_pro_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_pro.id
}
