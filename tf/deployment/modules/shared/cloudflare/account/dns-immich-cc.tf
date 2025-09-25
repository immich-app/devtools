resource "cloudflare_record" "immich_cc_aaaa_root" {
  name    = "immich.cc"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_cc.id
}

resource "cloudflare_record" "immich_cc_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_cc.id
}
