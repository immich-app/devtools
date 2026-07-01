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

locals {
  # CUSTOMER_ZITADEL_DOMAIN is stored as a URL (https://host/); Cloudflare needs
  # a bare hostname as CNAME content.
  customer_zitadel_host = trimsuffix(trimprefix(data.onepassword_item.customer_zitadel_domain.password, "https://"), "/")
}

# Prod only: auth.futo.cloud -> the prod ZITADEL Cloud instance host from
# CUSTOMER_ZITADEL_DOMAIN. dev/staging use the generated <name>.zitadel.cloud URL
# directly with no custom domain. DNS-only so ZITADEL terminates TLS.
resource "cloudflare_dns_record" "customer_auth" {
  count = var.env == "prod" ? 1 : 0

  zone_id = data.cloudflare_zone.futo_cloud.id
  name    = "auth.futo.cloud"
  type    = "CNAME"
  content = local.customer_zitadel_host
  ttl     = 1
  proxied = false
}
