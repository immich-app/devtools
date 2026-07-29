# Access to the bootstrap cluster's routed resources — the in-cluster
# 1Password Connect servers fronted by the Envoy gateway. The group is owned by
# the infra-bootstrap repo and referenced here by its live account name (verify
# if it changes), the same way yucca-o11y references it for its talos/CI peers.
data "netbird_group" "bootstrap_resources" {
  name = "bootstrap-resources"
}

# Allow yucca operators' workstations to reach the bootstrap resources over
# HTTPS — e.g. the onepassword provider talking to opc during local plans.
resource "netbird_policy" "yucca_to_bootstrap_resources" {
  name    = "yucca-to-bootstrap-resources"
  enabled = true

  rule {
    name          = "yucca-to-bootstrap-resources"
    action        = "accept"
    protocol      = "tcp"
    enabled       = true
    bidirectional = false
    sources       = [netbird_group.role["yucca"].id]
    destinations  = [data.netbird_group.bootstrap_resources.id]
    ports         = ["443"]
  }
}
