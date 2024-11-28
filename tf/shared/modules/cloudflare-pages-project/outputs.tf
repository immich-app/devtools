output "pages_project" {
  value = {
    id        = cloudflare_pages_project.project.id
    name      = cloudflare_pages_project.project.name
    subdomain = cloudflare_pages_project.project.subdomain
  }
}
