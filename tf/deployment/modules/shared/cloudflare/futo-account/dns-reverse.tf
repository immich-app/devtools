# Reverse DNS for the four /24s we own (69.48.224.0/24 – 69.48.227.0/24).
#
# For every IP 69.48.<octet>.<host> we manage, by default, a pair:
#   - PTR  <host>.<octet>.48.69.in-addr.arpa  ->  ip-69-48-<octet>-<host>.as402421.net
#   - A    ip-69-48-<octet>-<host>.as402421.net  ->  69.48.<octet>.<host>
# so reverse and forward agree (FCrDNS). The reverse zones live in zones.tf; the
# forward A records are created in the as402421.net zone (also in zones.tf).
#
# Overrides: list an IP in reverse_ptr_overrides to point its PTR at a name that
# is managed somewhere else (any domain). For an overridden IP we do NOT create a
# forward A record in as402421.net — the forward record is whatever owns that name.
locals {
  reverse_zone_ids = {
    "224" = cloudflare_zone.reverse_69_48_224.id
    "225" = cloudflare_zone.reverse_69_48_225.id
    "226" = cloudflare_zone.reverse_69_48_226.id
    "227" = cloudflare_zone.reverse_69_48_227.id
  }

  # Per-IP PTR target overrides. Key = full IPv4 address, value = target FQDN.
  # An overridden IP's PTR points at the given FQDN and gets NO A record here
  # (that forward record is managed elsewhere). Any IP not listed falls back to
  # ip-69-48-<octet>-<host>.as402421.net with a matching A record.
  # Example:
  #   "69.48.224.254" = "bob.something.something"
  reverse_ptr_overrides = {
  }

  # Every IP in the four /24s (1024), keyed "<octet>-<host>".
  reverse_ips = merge([
    for octet, zone_id in local.reverse_zone_ids : {
      for host in range(256) :
      "${octet}-${host}" => {
        zone_id     = zone_id
        ip          = "69.48.${octet}.${host}"
        ptr_name    = "${host}.${octet}.48.69.in-addr.arpa"
        default_fwd = "ip-69-48-${octet}-${host}.as402421.net"
      }
    }
  ]...)

  # PTR for every IP: override target if listed, else the default forward name.
  reverse_ptr_records = {
    for key, v in local.reverse_ips :
    key => {
      zone_id = v.zone_id
      name    = v.ptr_name
      content = lookup(local.reverse_ptr_overrides, v.ip, v.default_fwd)
    }
  }

  # Forward A records in as402421.net, only for IPs that are NOT overridden.
  forward_a_records = {
    for key, v in local.reverse_ips :
    key => {
      name    = v.default_fwd
      content = v.ip
    }
    if !contains(keys(local.reverse_ptr_overrides), v.ip)
  }
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

resource "cloudflare_dns_record" "reverse_forward_a" {
  for_each = local.forward_a_records

  zone_id = cloudflare_zone.as402421_net.id
  name    = each.value.name
  type    = "A"
  content = each.value.content
  ttl     = 1
  proxied = false
}
