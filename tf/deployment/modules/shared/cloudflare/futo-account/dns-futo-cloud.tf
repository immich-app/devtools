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

resource "cloudflare_dns_record" "futo_cloud_txt_spf" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "futo.cloud"
  type    = "TXT"
  content = "v=spf1 include:spf.messagingengine.com -all"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "futo_cloud_txt_dmarc" {
  zone_id = cloudflare_zone.futo_cloud.id
  name    = "_dmarc.futo.cloud"
  type    = "TXT"
  content = "v=DMARC1; p=reject; rua=mailto:bd9ccdafc3b44a88968d1f9889c853d9@dmarc-reports.cloudflare.net"
  ttl     = 1
  proxied = false
}
