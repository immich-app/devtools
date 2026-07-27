resource "cloudflare_dns_record" "futo_cloud_mx_root_10" {
  zone_id  = cloudflare_zone.futo_cloud.id
  name     = "futo.cloud"
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "futo_cloud_mx_root_20" {
  zone_id  = cloudflare_zone.futo_cloud.id
  name     = "futo.cloud"
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "futo_cloud_cname_dkim_fm1" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "fm1._domainkey.futo.cloud"
  type    = "CNAME"
  content = "fm1.futo.cloud.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_cname_dkim_fm2" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "fm2._domainkey.futo.cloud"
  type    = "CNAME"
  content = "fm2.futo.cloud.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_cname_dkim_fm3" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "fm3._domainkey.futo.cloud"
  type    = "CNAME"
  content = "fm3.futo.cloud.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_txt_dkim_postmark" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "20260722131929pm._domainkey.futo.cloud"
  type    = "TXT"
  content = "\"k=rsa;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCiWqKH70/oAeOCypulMdz4Ykde1SCWi91/DhRJI+sqcIjvRYl1aWn/8SAjZOUK5pwmqlsUFv4TwZJkra6t3/MWANexho1C36ShE/vohYjh5AclNtsV5x5gKVIP728BKOiupcSTMhH4MXY2tctekHrh/iWZJqKhtQDlyW0fXeFRjQIDAQAB\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_cname_postmark_bounces" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "pm-bounces.futo.cloud"
  type    = "CNAME"
  content = "pm.mtasv.net"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_txt_spf" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "futo.cloud"
  type    = "TXT"
  content = "\"v=spf1 include:spf.messagingengine.com -all\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_txt_dmarc" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "_dmarc.futo.cloud"
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; rua=mailto:bd9ccdafc3b44a88968d1f9889c853d9@dmarc-reports.cloudflare.net\""
  ttl     = 1
  proxied = false
}
