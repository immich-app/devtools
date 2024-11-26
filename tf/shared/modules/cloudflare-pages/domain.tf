module "domain" {
  source = "../domain"

  app_name = var.app_name
  stage = var.stage
  env = var.env
}

data "cloudflare_zone" "domain" {
  name = var.domain
}

resource "cloudflare_pages_domain" "pages_domain" {
  account_id   = var.cloudflare_account_id
  project_name = var.pages_project.name
  domain       = module.domain.fqdn
}

resource "cloudflare_record" "pages_subdomain" {
  name    = module.domain.fqdn
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "${local.pages_url_prefix}${var.pages_project.subdomain}"
  zone_id = data.cloudflare_zone.domain.zone_id
}
