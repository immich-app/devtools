output "pages_branch" {
  value = local.pages_branch
}

output "pages_project_name" {
  value = var.pages_project.name
}

output "branch_subdomain" {
  value = cloudflare_record.pages_subdomain.hostname
}

output "pages_branch_subdomain" {
  value = cloudflare_record.pages_subdomain.content
}
