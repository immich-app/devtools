resource "bunnynet_dns_zone" "reverse_69_48_224" {
  domain = "224.48.69.in-addr.arpa"
}

resource "bunnynet_dns_zone" "reverse_69_48_225" {
  domain = "225.48.69.in-addr.arpa"
}

resource "bunnynet_dns_zone" "reverse_69_48_226" {
  domain = "226.48.69.in-addr.arpa"
}

resource "bunnynet_dns_zone" "reverse_69_48_227" {
  domain = "227.48.69.in-addr.arpa"
}

# Forward (FCrDNS) names live here; delegated to bunny from the Cloudflare
# as402421.net zone via NS records.
resource "bunnynet_dns_zone" "rdns_as402421_net" {
  domain = "rdns.as402421.net"
}
