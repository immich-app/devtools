# Publish the managed zone IDs into the shared_tf vault as part of zone setup, so other
# modules and humans can consume them without needing a Zone Read-capable Cloudflare
# token. In particular cloudflare/futo-api-keys reads FUTO_NETWORK_ZONE_ID from here to
# mint a futo.network-scoped DNS token (its bootstrap CLOUDFLARE_API_TOKEN only has
# "Account API Tokens Write", so it cannot resolve zones via the Cloudflare API itself).
#
# local.zones is defined in zones.tf (keys: futo_cloud, futo_network, as402421_net);
# data.onepassword_vault.shared_tf is defined in data.tf. Titles become e.g.
# FUTO_NETWORK_ZONE_ID, FUTO_CLOUD_ZONE_ID, AS402421_NET_ZONE_ID.
resource "onepassword_item" "zone_ids" {
  for_each = local.zones

  vault    = data.onepassword_vault.shared_tf.uuid
  title    = "${upper(each.key)}_ZONE_ID"
  category = "password"
  password = each.value
}
