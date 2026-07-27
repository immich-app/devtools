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

# Prod only: auth.futo.cloud -> the prod ZITADEL Cloud instance's base
# <name>.zitadel.cloud host from CUSTOMER_ZITADEL_BASE_DOMAIN, which is stored as
# a bare hostname (no scheme) — exactly what a CNAME wants. This is NOT the
# auth.futo.cloud vanity domain that CUSTOMER_ZITADEL_DOMAIN holds; pointing the
# record at the vanity domain would make the CNAME reference itself. dev/staging
# have no custom domain and use the generated URL directly. DNS-only so ZITADEL
# terminates TLS.
resource "cloudflare_dns_record" "customer_auth" {
  count = var.env == "prod" ? 1 : 0

  zone_id = data.cloudflare_zone.futo_cloud.id
  name    = "auth.futo.cloud"
  type    = "CNAME"
  content = data.onepassword_item.customer_zitadel_base_domain.password
  ttl     = 1
  proxied = false
}
