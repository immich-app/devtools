# Make the account default-deny.
#
# NetBird is implicit-deny: with no allow-all policy in place, a peer can only
# reach what an explicit netbird_policy permits. NetBird ships a built-in
# "Default" policy that allows All -> All, which makes the mesh effectively
# allow-all. We adopt that policy and disable it, so access is governed solely
# by explicit policies (e.g. netbird_policy.liberty_park_all_access).
#
# The policy is imported by name rather than a hardcoded ID. This is reversible:
# set enabled = true to restore the original allow-all behaviour.
#
# data.netbird_group.all is defined in liberty-park.tf.
data "netbird_policy" "default" {
  name = "Default"
}

import {
  to = netbird_policy.default
  id = data.netbird_policy.default.id
}

resource "netbird_policy" "default" {
  name    = "Default"
  enabled = false

  # Mirrors the built-in All -> All rule so adopting the policy is a clean
  # no-op apart from disabling it.
  rule {
    name          = "Default"
    action        = "accept"
    bidirectional = true
    enabled       = false
    protocol      = "all"
    sources       = [data.netbird_group.all.id]
    destinations  = [data.netbird_group.all.id]
  }
}
