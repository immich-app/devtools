# Distribute the futo_bootstrap cert-manager Cloudflare token into the shared_tf
# vault. The bootstrap cluster's cert-manager DNS-01 solver consumes this (scoped
# to Zone Read + DNS Write on futo.network only). data.onepassword_vault.shared_tf
# is declared in data.tf.
resource "onepassword_item" "futo_bootstrap_cert_manager_cloudflare" {
  vault    = data.onepassword_vault.shared_tf.uuid
  title    = "FUTO_BOOTSTRAP_CLOUDFLARE_API_TOKEN"
  category = "password"
  password = cloudflare_account_token.futo_bootstrap_cert_manager.value
}

# Distribute the general-purpose futo.network DNS-edit token into the shared_tf vault so
# any project can manage futo.network DNS records. Scoped to Zone Read + DNS Write on the
# futo.network zone only (see api-keys.tf). data.onepassword_vault.shared_tf is in data.tf.
resource "onepassword_item" "futo_network_dns_cloudflare" {
  vault    = data.onepassword_vault.shared_tf.uuid
  title    = "FUTO_NETWORK_DNS_CLOUDFLARE_API_TOKEN"
  category = "password"
  password = cloudflare_account_token.futo_network_dns.value
}
