resource "cloudflare_record" "immich_app_a_demo" {
  name    = "demo"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "158.101.217.188"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_aaaa_docs" {
  name    = "docs"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = "100::"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_aaaa_documentation" {
  name    = "documentation"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  value   = "100::"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_cname__domainconnect" {
  name    = "_domainconnect"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "connect.domains.google.com"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_mx_root_35" {
  name     = "immich.app"
  priority = 35
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "route1.mx.cloudflare.net"
  zone_id  = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_mx_root_54" {
  name     = "immich.app"
  priority = 54
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "route3.mx.cloudflare.net"
  zone_id  = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_mx_root_73" {
  name     = "immich.app"
  priority = 73
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "route2.mx.cloudflare.net"
  zone_id  = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_txt_root_cloudflare_mx" {
  name    = "immich.app"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_txt_1password_verification" {
  name    = "immich.app"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "\"1password-site-verification=GPHHHHLRXZHQFKUCAEYLDTI4TM\""
  zone_id = cloudflare_zone.immich_app.id
}
