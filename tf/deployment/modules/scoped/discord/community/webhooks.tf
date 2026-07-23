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

# Publish the yucca-alerts Grafana webhook URLs into the FUTO o11y vaults so the o11y
# stack can consume them. The o11y_tf_* vaults live in the FUTO 1Password account, which
# the default (immich Connect) provider cannot reach — hence provider = onepassword.futo.
#
# Gated to the prod apply only: this module also runs in dev against the test Discord
# server, and an ungated write would clobber the real webhook URLs with dev-server ones
# on every dev apply (the dev-env service account may not have o11y vault access either,
# which is also why the data sources are gated — they execute during every plan).
# yucca-alerts-staging lives on the same prod community server, so both vault items are
# written from the single prod apply.
data "onepassword_vault" "o11y_tf_prod" {
  count    = var.env == "prod" ? 1 : 0
  provider = onepassword.futo
  name     = "o11y_tf_prod"
}

data "onepassword_vault" "o11y_tf_staging" {
  count    = var.env == "prod" ? 1 : 0
  provider = onepassword.futo
  name     = "o11y_tf_staging"
}

resource "onepassword_item" "o11y_prod_grafana_discord_webhook" {
  count    = var.env == "prod" ? 1 : 0
  provider = onepassword.futo
  vault    = data.onepassword_vault.o11y_tf_prod[0].uuid
  title    = "GRAFANA_DISCORD_WEBHOOK"
  category = "password"
  password = discord_webhook.yucca_alerts_grafana.url
}

resource "onepassword_item" "o11y_staging_grafana_discord_webhook" {
  count    = var.env == "prod" ? 1 : 0
  provider = onepassword.futo
  vault    = data.onepassword_vault.o11y_tf_staging[0].uuid
  title    = "GRAFANA_DISCORD_WEBHOOK"
  category = "password"
  password = discord_webhook.yucca_alerts_staging_grafana.url
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
