resource "discord_webhook" "leadership_alerts_grafana" {
  name            = "Grafana"
  channel_id      = discord_text_channel.leadership_alerts.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "leadership_alerts_grafana_webhook_url" {
  value     = discord_webhook.leadership_alerts_grafana.url
  sensitive = true
}

// Consumed by cloudflare/account/alerts.tf for the R2 billing notification
// policies. Previously a hand-created Discord webhook stored in the legacy
// "OpenTofu" 1Password vault; terraform owns it now so there's no manual secret.
resource "discord_webhook" "leadership_alerts_cloudflare" {
  name       = "Cloudflare"
  channel_id = discord_text_channel.leadership_alerts.id
}

output "leadership_alerts_cloudflare_webhook_url" {
  value     = discord_webhook.leadership_alerts_cloudflare.url
  sensitive = true
}

resource "discord_webhook" "team_alerts_grafana" {
  name            = "Grafana"
  channel_id      = discord_text_channel.team_alerts.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "team_alerts_grafana_webhook_url" {
  value     = discord_webhook.team_alerts_grafana.url
  sensitive = true
}

resource "discord_webhook" "yucca_alerts_dev_grafana" {
  name            = "Grafana Dev"
  channel_id      = discord_text_channel.yucca_alerts_dev.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "yucca_alerts_dev_grafana_webhook_url" {
  value     = discord_webhook.yucca_alerts_dev_grafana.url
  sensitive = true
}

resource "discord_webhook" "yucca_alerts_dev_victoriametrics" {
  name            = "VictoriaMetrics Dev"
  channel_id      = discord_text_channel.yucca_alerts_dev.id
  avatar_data_uri = local.image_data_uris["VictoriaMetrics-symbol-white.jpg"]
}

output "yucca_alerts_dev_victoriametrics_webhook_url" {
  value     = discord_webhook.yucca_alerts_dev_victoriametrics.url
  sensitive = true
}
