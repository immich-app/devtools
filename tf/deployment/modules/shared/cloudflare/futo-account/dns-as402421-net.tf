resource "cloudflare_dns_record" "as402421_net_mx_root_10" {
  zone_id  = cloudflare_zone.as402421_net.id
  name     = "as402421.net"
  type     = "MX"
  content  = "in1-smtp.messagingengine.com"
  priority = 10
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "as402421_net_mx_root_20" {
  zone_id  = cloudflare_zone.as402421_net.id
  name     = "as402421.net"
  type     = "MX"
  content  = "in2-smtp.messagingengine.com"
  priority = 20
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "as402421_net_cname_dkim_fm1" {
  zone_id = cloudflare_zone.as402421_net.id
  name    = "fm1._domainkey.as402421.net"
  type    = "CNAME"
  content = "fm1.as402421.net.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "as402421_net_cname_dkim_fm2" {
  zone_id = cloudflare_zone.as402421_net.id
  name    = "fm2._domainkey.as402421.net"
  type    = "CNAME"
  content = "fm2.as402421.net.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "as402421_net_cname_dkim_fm3" {
  zone_id = cloudflare_zone.as402421_net.id
  name    = "fm3._domainkey.as402421.net"
  type    = "CNAME"
  content = "fm3.as402421.net.dkim.fmhosted.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "as402421_net_txt_spf" {
  zone_id = cloudflare_zone.as402421_net.id
  name    = "as402421.net"
  type    = "TXT"
  content = "v=spf1 include:spf.messagingengine.com -all"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "as402421_net_txt_dmarc" {
  zone_id = cloudflare_zone.as402421_net.id
  name    = "_dmarc.as402421.net"
  type    = "TXT"
  content = "v=DMARC1; p=reject; rua=mailto:2225ea925e8d4b4580af7e5744f181db@dmarc-reports.cloudflare.net"
  ttl     = 1
  proxied = false
}

# Delegate rdns.as402421.net to bunny.net, where the reverse-DNS forward (FCrDNS)
# names are managed (see bunny/futo-account).
resource "cloudflare_dns_record" "as402421_net_ns_rdns" {
  for_each = toset(["kiki.bunny.net", "coco.bunny.net"])

  zone_id = cloudflare_zone.as402421_net.id
  name    = "rdns.as402421.net"
  type    = "NS"
  content = each.value
  ttl     = 1
  proxied = false
}
