resource "cloudflare_pages_project" "project" {
  account_id        = var.cloudflare_account_id
  name              = local.sanitised_project_name
  production_branch = var.env

  build_config {
    web_analytics_tag   = cloudflare_web_analytics_site.analytics.site_tag
    web_analytics_token = cloudflare_web_analytics_site.analytics.site_token
  }

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
    ]
  }
}

data "cloudflare_zone" "zone" {
  name = var.domain
}

module "domain" {
  source = "../domain"

  app_name = var.app_name
  env      = var.env
}

resource "cloudflare_web_analytics_site" "analytics" {
  account_id   = var.cloudflare_account_id
  host         = module.domain.fqdn
  auto_install = false
}
