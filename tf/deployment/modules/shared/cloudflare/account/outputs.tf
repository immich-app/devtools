output "cloudflare_account_id" {
  value = var.cloudflare_account_id
}

output "turnstile_default_invisible_secret" {
  value     = cloudflare_turnstile_widget.default_invisible.secret
  sensitive = true
}

output "turnstile_default_invisible_site_key" {
  value = cloudflare_turnstile_widget.default_invisible.id
} 