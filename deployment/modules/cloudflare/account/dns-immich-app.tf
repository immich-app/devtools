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

resource "cloudflare_record" "immich_app_aaaa_discord" {
  name    = "discord"
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

resource "cloudflare_record" "immich_app_cname_api" {
  name    = "api.immich.app"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "mich.immich.cloud"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_mx_root_10" {
  name     = "immich.app"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "in1-smtp.messagingengine.com"
  zone_id  = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_mx_root_20" {
  name     = "immich.app"
  priority = 20
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "in2-smtp.messagingengine.com"
  zone_id  = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_cname_dkim_fm1" {
  name    = "fm1._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "fm1.immich.app.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_cname_dkim_fm2" {
  name    = "fm2._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "fm2.immich.app.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_cname_dkim_fm3" {
  name    = "fm3._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "fm3.immich.app.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_txt_root_fastmail_mx" {
  name    = "@"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 include:spf.messagingengine.com ?all"
  zone_id = cloudflare_zone.immich_app.id
}

resource "cloudflare_record" "immich_app_txt_1password_verification" {
  name    = "immich.app"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "1password-site-verification=GPHHHHLRXZHQFKUCAEYLDTI4TM"
  zone_id = cloudflare_zone.immich_app.id
}
