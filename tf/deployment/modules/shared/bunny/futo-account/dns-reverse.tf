# Reverse DNS for the four /24s we own (69.48.224.0/24 – 69.48.227.0/24).
#
# For every IP 69.48.<octet>.<host> we manage, by default a pair:
#   - PTR  <host> in <octet>.48.69.in-addr.arpa  ->  ip-69-48-<octet>-<host>.rdns.as402421.net
#   - A    ip-69-48-<octet>-<host> in rdns.as402421.net  ->  69.48.<octet>.<host>
# so reverse and forward agree (FCrDNS). The zones live in zones.tf.
#
# Overrides: list an IP in reverse_ptr_overrides to point its PTR at a name that
# is managed somewhere else (any domain). An overridden IP gets NO A record here
# (that forward record is managed elsewhere).
locals {
  reverse_zone_ids = {
    "224" = bunnynet_dns_zone.reverse_69_48_224.id
    "225" = bunnynet_dns_zone.reverse_69_48_225.id
    "226" = bunnynet_dns_zone.reverse_69_48_226.id
    "227" = bunnynet_dns_zone.reverse_69_48_227.id
  }

  # Per-IP PTR target overrides. Key = full IPv4 address, value = target FQDN.
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
        ptr_name    = tostring(host)              # relative to <octet>.48.69.in-addr.arpa
        fwd_name    = "ip-69-48-${octet}-${host}" # relative to rdns.as402421.net
        default_fwd = "ip-69-48-${octet}-${host}.rdns.as402421.net"
      }
    }
  ]...)

  # PTR for every IP: override target if listed, else the default forward name.
  reverse_ptr_records = {
    for key, v in local.reverse_ips :
    key => {
      zone  = v.zone_id
      name  = v.ptr_name
      value = lookup(local.reverse_ptr_overrides, v.ip, v.default_fwd)
    }
  }

  # Forward A records in rdns.as402421.net, only for IPs that are NOT overridden.
  forward_a_records = {
    for key, v in local.reverse_ips :
    key => {
      name  = v.fwd_name
      value = v.ip
    }
    if !contains(keys(local.reverse_ptr_overrides), v.ip)
  }
}

resource "bunnynet_dns_record" "reverse_ptr" {
  for_each = local.reverse_ptr_records

  zone  = each.value.zone
  name  = each.value.name
  type  = "PTR"
  value = each.value.value
  ttl   = 3600
}

resource "bunnynet_dns_record" "reverse_forward_a" {
  for_each = local.forward_a_records

  zone  = bunnynet_dns_zone.rdns_as402421_net.id
  name  = each.value.name
  type  = "A"
  value = each.value.value
  ttl   = 3600
}
