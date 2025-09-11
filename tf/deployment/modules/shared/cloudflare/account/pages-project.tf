// Old archives prior to docs.immich.app
resource "cloudflare_pages_project" "immich_app_archive" {
  account_id        = var.cloudflare_account_id
  name              = "immich-app-archive"
  production_branch = "we-will-never-use-this"

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
      build_config["web_analytics_tag"],
      build_config["web_analytics_token"],
    ]
  }
}

resource "cloudflare_pages_project" "docs_immich_app_archive" {
  account_id        = var.cloudflare_account_id
  name              = "docs-immich-app-archive"
  production_branch = "we-will-never-use-this"

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
      build_config["web_analytics_tag"],
      build_config["web_analytics_token"],
    ]
  }
}

output "immich_app_archive_pages_project_name" {
  value = cloudflare_pages_project.docs_immich_app_archive.name
}

output "immich_app_archive_pages_project_subdomain" {
  value = cloudflare_pages_project.docs_immich_app_archive.subdomain
}

resource "cloudflare_pages_project" "immich_app_preview" {
  account_id        = var.cloudflare_account_id
  name              = "immich-app-preview"
  production_branch = "we-will-never-use-this"

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
      build_config["web_analytics_tag"],
      build_config["web_analytics_token"],
    ]
  }
}

output "immich_app_preview_pages_project_name" {
  value = cloudflare_pages_project.immich_app_preview.name
}

output "immich_app_preview_pages_project_subdomain" {
  value = cloudflare_pages_project.immich_app_preview.subdomain
}

locals {
  static_pages = ["my.immich.app", "buy.immich.app", "get.immich.app", "data.immich.app", "next.immich.app"]
}

resource "cloudflare_pages_project" "static_pages" {
  for_each          = { for page in local.static_pages : page => page }
  account_id        = var.cloudflare_account_id
  name              = "${split(".", each.value)[0]}-immich-app"
  production_branch = "prod"

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
      build_config["web_analytics_tag"],
      build_config["web_analytics_token"],
    ]
  }
}

output "static_pages_project_names" {
  value = { for page in local.static_pages : page => cloudflare_pages_project.static_pages[page].name }
}

output "static_pages_project_subdomains" {
  value = { for page in local.static_pages : page => cloudflare_pages_project.static_pages[page].subdomain }
}

output "pages_projects" {
  value = { for page in local.static_pages : page =>
    {
      name : cloudflare_pages_project.static_pages[page].name,
      subdomain : cloudflare_pages_project.static_pages[page].subdomain
    }
  }
}
