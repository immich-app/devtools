resource "discord_webhook" "leadership_alerts_grafana" {
  name            = "Grafana"
  channel_id      = discord_text_channel.leadership_alerts.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "leadership_alerts_grafana_webhook_url" {
  value     = discord_webhook.leadership_alerts_grafana.url
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
