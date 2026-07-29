data "netbird_group" "bootstrap_resources" {
  name = "bootstrap-resources"
}

# Allow yucca operators' workstations to reach the bootstrap resources over HTTPS
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
