resource "cloudflare_record" "immich_store_a_demo_root" {
  name    = "@"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "34.117.223.165"
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_www" {
  name    = "www"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "immich.store"
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_em_fw_support" {
  name    = "em-fw.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "u48267109.wl110.sendgrid.net."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_s1__domainkey_support" {
  name    = "s1._domainkey.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "s1.domainkey.u48267109.wl110.sendgrid.net."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_s2__domainkey_support" {
  name    = "s2._domainkey.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "s2.domainkey.u48267109.wl110.sendgrid.net."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk1__domainkey_support" {
  name    = "zendesk1._domainkey.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "zendesk1._domainkey.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk2__domainkey_support" {
  name    = "zendesk2._domainkey.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "zendesk2._domainkey.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk1_support" {
  name    = "zendesk1.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mail1.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk2_support" {
  name    = "zendesk2.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mail2.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk3_support" {
  name    = "zendesk3.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mail3.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_zendesk4_support" {
  name    = "zendesk4.support"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mail4.zendesk.com."
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_txt_zendeskverification_support" {
  name    = "zendeskverification.support"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"66c266412210c4b5\""
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_txt__dmarc_support" {
  name    = "_dmarc.support"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; pct=100; rua=mailto:dmarc@fourthwall.com\""
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_txt_support" {
  name    = "support"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com include:mail.zendesk.com include:spf.improvmx.com include:sendgrid.net ~all\""
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_mx_support_10" {
  name     = "support"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx1.improvmx.com."
  zone_id  = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_mx_support_20" {
  name     = "support"
  priority = 20
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx2.improvmx.com."
  zone_id  = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_mx_root_10" {
  name     = "@"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  zone_id  = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_mx_root_20" {
  name     = "@"
  priority = 20
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  zone_id  = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_dkim_fm1" {
  name    = "fm1._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "fm1.immich.store.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_dkim_fm2" {
  name    = "fm2._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "fm2.immich.store.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_cname_dkim_fm3" {
  name    = "fm3._domainkey"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "fm3.immich.store.dkim.fmhosted.com"
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_txt_root_fastmail_mx" {
  name    = "@"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:spf.messagingengine.com -all\""
  zone_id = cloudflare_zone.immich_store.id
}

resource "cloudflare_record" "immich_store_txt_dmarc_immich_store" {
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; rua=mailto:4ea3569cc6be4e8db43bcfa1318d88ce@dmarc-reports.cloudflare.net\""
  zone_id = cloudflare_zone.immich_store.id
}
