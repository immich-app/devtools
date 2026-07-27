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

resource "discord_webhook" "yucca_alerts_grafana" {
  name            = "Grafana"
  channel_id      = discord_text_channel.yucca_alerts.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "yucca_alerts_grafana_webhook_url" {
  value     = discord_webhook.yucca_alerts_grafana.url
  sensitive = true
}

resource "discord_webhook" "yucca_alerts_staging_grafana" {
  name            = "Grafana Staging"
  channel_id      = discord_text_channel.yucca_alerts_staging.id
  avatar_data_uri = local.image_data_uris["grafana_128_128.webp"]
}

output "yucca_alerts_staging_grafana_webhook_url" {
  value     = discord_webhook.yucca_alerts_staging_grafana.url
  sensitive = true
}

# Publish each cluster's yucca-alerts Grafana webhook URL into its FUTO o11y vault
# (o11y_tf_<env>) so the o11y stack can consume it. The o11y_tf_* vaults live in the
# FUTO 1Password account, which the default (immich Connect) provider cannot reach —
# hence provider = onepassword.futo.
#
# All three yucca-alerts channels live on the community server, which only the prod
# discord apply manages — the dev apply targets the test server and would clobber the
# vault items with test-server URLs on every run (its service account may not have o11y
# vault access either, and data sources execute during every plan). Hence the for_each
# collapses to an empty map outside prod.
locals {
  o11y_grafana_discord_webhooks = {
    prod    = discord_webhook.yucca_alerts_grafana.url
    staging = discord_webhook.yucca_alerts_staging_grafana.url
    dev     = discord_webhook.yucca_alerts_dev_grafana.url
  }
}

data "onepassword_vault" "o11y_tf" {
  for_each = { for env, url in local.o11y_grafana_discord_webhooks : env => url if var.env == "prod" }
  provider = onepassword.futo
  name     = "o11y_tf_${each.key}"
}

resource "onepassword_item" "o11y_grafana_discord_webhook" {
  for_each = { for env, url in local.o11y_grafana_discord_webhooks : env => url if var.env == "prod" }
  provider = onepassword.futo
  vault    = data.onepassword_vault.o11y_tf[each.key].uuid
  title    = "GRAFANA_DISCORD_WEBHOOK"
  category = "password"
  password = each.value
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
