resource "cloudflare_record" "immich_ca_aaaa_root" {
  name    = "immich.ca"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_ca.id
}

resource "cloudflare_record" "immich_ca_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_ca.id
}
