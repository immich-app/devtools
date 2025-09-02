data "onepassword_vault" "opentofu_vault" {
  name = "OpenTofu"
}

data "onepassword_item" "discord_leadership_alerts" {
  title = "discord-leadership-alerts-webhook"
  vault = data.onepassword_vault.opentofu_vault.name
}

locals {
  alerts_email = "alerts@immich.app"
}

resource "cloudflare_notification_policy" "r2_storage_usage_alert" {
  account_id  = var.cloudflare_account_id
  name        = "R2 storage usage billing alert"
  description = "R2 storage usage exceeded set billing limit"
  enabled     = true
  alert_type  = "billing_usage_alert"

  filters = {
    limit   = ["2000000000000"] // 2TB
    product = ["r2_storage"]
  }

  email_integration = [{
    id = local.alerts_email
  }]

  webhooks_integration = [{
    id   = cloudflare_notification_policy_webhooks.discord_leadership_alert.id
    name = cloudflare_notification_policy_webhooks.discord_leadership_alert.name
  }]
}

resource "cloudflare_notification_policy" "r2_class_a_operations_alert" {
  account_id  = var.cloudflare_account_id
  name        = "R2 class A operation usage billing alert"
  description = "R2 class A operation usage exceeded set billing limit"
  enabled     = true
  alert_type  = "billing_usage_alert"

  filters = {
    limit   = ["500000"]
    product = ["r2_class_a_operations"]
  }

  email_integration = [{
    id = local.alerts_email
  }]

  webhooks_integration = [{
    id   = cloudflare_notification_policy_webhooks.discord_leadership_alert.id
    name = cloudflare_notification_policy_webhooks.discord_leadership_alert.name
  }]
}

resource "cloudflare_notification_policy" "r2_class_b_operations_alert" {
  account_id  = var.cloudflare_account_id
  name        = "R2 class B operation usage billing alert"
  description = "R2 class B operation usage exceeded set billing limit"
  enabled     = true
  alert_type  = "billing_usage_alert"

  filters = {
    limit   = ["5000000"]
    product = ["r2_class_b_operations"]
  }

  email_integration = [{
    id = local.alerts_email
  }]

  webhooks_integration = [{
    id   = cloudflare_notification_policy_webhooks.discord_leadership_alert.id
    name = cloudflare_notification_policy_webhooks.discord_leadership_alert.name
  }]
}

resource "cloudflare_notification_policy_webhooks" "discord_leadership_alert" {
  account_id = var.cloudflare_account_id
  name       = "Discord Leadership Alerts"
  url        = data.onepassword_item.discord_leadership_alerts.hostname
  secret     = data.onepassword_item.discord_leadership_alerts.credential
}
