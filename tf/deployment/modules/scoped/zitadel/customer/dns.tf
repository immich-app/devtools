data "terraform_remote_state" "futo_cloudflare_api_keys" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_futo_api_keys"
  }
}

data "cloudflare_zone" "futo_cloud" {
  filter = {
    name = "futo.cloud"
  }
}

# Prod only: auth.futo.cloud -> the prod instance URL, which is exactly what
# CUSTOMER_ZITADEL_DOMAIN holds (the provider connects to it). dev/staging use
# the generated <name>.zitadel.cloud URL directly with no custom domain.
# DNS-only so ZITADEL terminates TLS for the custom domain.
resource "cloudflare_dns_record" "customer_auth" {
  count = var.env == "prod" ? 1 : 0

  zone_id = data.cloudflare_zone.futo_cloud.id
  name    = "auth.futo.cloud"
  type    = "CNAME"
  content = data.onepassword_item.customer_zitadel_domain.password
  ttl     = 1
  proxied = false
}
