# Liberty Park site routing.
#
# The "red" server is an existing NetBird peer at Liberty Park. It acts as the
# routing peer that advertises the site's subnets into the mesh. Modeled as a
# single NetBird Network with one router (red) and one resource per subnet.
#
# NOTE: routing only. NetBird's distributed firewall blocks traffic to these
# resources until a netbird_policy grants access — add one (sources -> the
# resource groups below) when we decide who may reach Liberty Park.

# Look up the existing "red" peer by name so we can attach it as the router.
data "netbird_peer" "red" {
  name = "red"
}

resource "netbird_network" "liberty_park" {
  name        = "Liberty Park"
  description = "Liberty Park site subnets, routed by the red server."
}

# red routes the whole network. masquerade so return traffic works without
# adding routes on each destination host.
resource "netbird_network_router" "liberty_park" {
  network_id = netbird_network.liberty_park.id
  peer       = data.netbird_peer.red.id
  metric     = 9999
  masquerade = true
  enabled    = true
}

# One resource per advertised subnet. Each gets its own group so access policies
# can target subnets individually later.
resource "netbird_group" "liberty_park_servers" {
  name = "Liberty Park Servers"
}

resource "netbird_network_resource" "liberty_park_servers" {
  network_id  = netbird_network.liberty_park.id
  name        = "Liberty Park Servers"
  description = "LIBERTY_PARK_SERVERS"
  address     = "10.10.10.0/24"
  groups      = [netbird_group.liberty_park_servers.id]
  enabled     = true
}

resource "netbird_group" "liberty_park_compute" {
  name = "Liberty Park Compute"
}

resource "netbird_network_resource" "liberty_park_compute" {
  network_id  = netbird_network.liberty_park.id
  name        = "Liberty Park Compute"
  description = "LIBERTY_PARK_COMPUTE"
  address     = "10.50.0.0/16"
  groups      = [netbird_group.liberty_park_compute.id]
  enabled     = true
}

resource "netbird_group" "liberty_park_services" {
  name = "Liberty Park Services"
}

resource "netbird_network_resource" "liberty_park_services" {
  network_id  = netbird_network.liberty_park.id
  name        = "Liberty Park Services"
  description = "LIBERTY_PARK_SERVICES"
  address     = "10.51.0.0/16"
  groups      = [netbird_group.liberty_park_services.id]
  enabled     = true
}

resource "netbird_group" "liberty_park_server_monitoring" {
  name = "Liberty Park Server Monitoring"
}

resource "netbird_network_resource" "liberty_park_server_monitoring" {
  network_id  = netbird_network.liberty_park.id
  name        = "Liberty Park Server Monitoring"
  description = "LIBERTY_PARK_SERVER_MONITORING"
  address     = "10.10.11.0/24"
  groups      = [netbird_group.liberty_park_server_monitoring.id]
  enabled     = true
}

# Built-in "All" group — every peer in the account.
data "netbird_group" "all" {
  name = "All"
}

# Allow everyone and everything to reach all of red's exposed Liberty Park
# subnets. Bidirectional so the routed hosts can also initiate back to peers.
resource "netbird_policy" "liberty_park_all_access" {
  name    = "Liberty Park - All Access"
  enabled = true

  rule {
    name          = "Liberty Park - All Access"
    action        = "accept"
    bidirectional = true
    enabled       = true
    protocol      = "all"
    sources       = [data.netbird_group.all.id]
    destinations = [
      netbird_group.liberty_park_servers.id,
      netbird_group.liberty_park_compute.id,
      netbird_group.liberty_park_services.id,
      netbird_group.liberty_park_server_monitoring.id,
    ]
  }
}
