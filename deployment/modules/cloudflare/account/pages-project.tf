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

output "immich_app_archive_pages_project_name" {
  value = cloudflare_pages_project.immich_app_archive.name
}

output "immich_app_archive_pages_project_subdomain" {
  value = cloudflare_pages_project.immich_app_archive.subdomain
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

resource "cloudflare_pages_project" "my_immich_app" {
  account_id        = var.cloudflare_account_id
  name              = "my-immich-app"
  production_branch = "main"

  lifecycle {
    ignore_changes = [
      build_config["build_caching"],
      build_config["web_analytics_tag"],
      build_config["web_analytics_token"],
    ]
  }
}

output "my_immich_app_pages_project_name" {
  value = cloudflare_pages_project.my_immich_app.name
}

output "my_immich_app_pages_project_subdomain" {
  value = cloudflare_pages_project.my_immich_app.subdomain
}
