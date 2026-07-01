# Reverse DNS (PTR) records for every IP in the four /24s we own
# (69.48.224.0/24 – 69.48.227.0/24). Each IP 69.48.<octet>.<host> points at
# ip-69-48-<octet>-<host>.as402421.net (forward records live in the as402421.net
# zone and are managed elsewhere). Zones are defined in zones.tf.
locals {
  reverse_zone_ids = {
    "224" = cloudflare_zone.reverse_69_48_224.id
    "225" = cloudflare_zone.reverse_69_48_225.id
    "226" = cloudflare_zone.reverse_69_48_226.id
    "227" = cloudflare_zone.reverse_69_48_227.id
  }

  # Per-IP PTR target overrides. Key = full IPv4 address, value = target FQDN.
  # Any IP not listed here falls back to ip-69-48-<octet>-<host>.as402421.net.
  # Example:
  #   "69.48.224.225" = "mail.as402421.net"
  reverse_ptr_overrides = {
  }

  # One PTR per host octet (0-255) in each /24 => 1024 records, keyed "<octet>-<host>".
  reverse_ptr_records = merge([
    for octet, zone_id in local.reverse_zone_ids : {
      for host in range(256) :
      "${octet}-${host}" => {
        zone_id = zone_id
        name    = "${host}.${octet}.48.69.in-addr.arpa"
        content = lookup(
          local.reverse_ptr_overrides,
          "69.48.${octet}.${host}",
          "ip-69-48-${octet}-${host}.as402421.net",
        )
      }
    }
  ]...)
}

resource "cloudflare_dns_record" "reverse_ptr" {
  for_each = local.reverse_ptr_records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = "PTR"
  content = each.value.content
  ttl     = 1
  proxied = false
}
