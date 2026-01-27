resource "github_actions_organization_secret" "cloudflare_api_token_pages_upload" {
  secret_name     = "CLOUDFLARE_API_TOKEN_PAGES_UPLOAD"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_pages_upload
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.cloudflare_api_token_pages_upload
  id = "CLOUDFLARE_API_TOKEN_PAGES_UPLOAD"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_id" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_ID"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_id
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.tiles_r2_kv_token_id
  id = "CLOUDFLARE_TILES_R2_KV_TOKEN_ID"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_value" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_VALUE"
  plaintext_value = data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_value
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.tiles_r2_kv_token_value
  id = "CLOUDFLARE_TILES_R2_KV_TOKEN_VALUE"
}

resource "github_actions_organization_secret" "tiles_r2_kv_token_hashed_value" {
  secret_name     = "CLOUDFLARE_TILES_R2_KV_TOKEN_HASHED_VALUE"
  plaintext_value = sha256(data.terraform_remote_state.api_keys_state.outputs.tiles_r2_kv_token_value)
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.tiles_r2_kv_token_hashed_value
  id = "CLOUDFLARE_TILES_R2_KV_TOKEN_HASHED_VALUE"
}

data "onepassword_item" "push_o_matic_app" {
  title = "push-o-matic-app"
  vault = data.onepassword_vault.github.name
}

locals {
  push_o_matic_fields = {
    app_id          = [for field in data.onepassword_item.push_o_matic_app.section[0].field : field.value if field.label == "app_id"][0]
    installation_id = [for field in data.onepassword_item.push_o_matic_app.section[0].field : field.value if field.label == "installation_id"][0]
  }
}

resource "github_actions_organization_secret" "push_o_matic_app_id" {
  secret_name     = "PUSH_O_MATIC_APP_ID"
  plaintext_value = local.push_o_matic_fields.app_id
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.push_o_matic_app_id
  id = "PUSH_O_MATIC_APP_ID"
}

resource "github_actions_organization_secret" "push_o_matic_app_installation_id" {
  secret_name     = "PUSH_O_MATIC_APP_INSTALLATION_ID"
  plaintext_value = local.push_o_matic_fields.installation_id
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.push_o_matic_app_installation_id
  id = "PUSH_O_MATIC_APP_INSTALLATION_ID"
}

resource "github_actions_organization_secret" "push_o_matic_app_key" {
  secret_name     = "PUSH_O_MATIC_APP_KEY"
  plaintext_value = data.onepassword_item.push_o_matic_app.private_key
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.push_o_matic_app_key
  id = "PUSH_O_MATIC_APP_KEY"
}

resource "github_actions_organization_secret" "docker_hub_read_token" {
  secret_name     = "DOCKER_HUB_READ_TOKEN"
  plaintext_value = data.terraform_remote_state.docker_org_state.outputs.read_token
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.docker_hub_read_token
  id = "DOCKER_HUB_READ_TOKEN"
}

resource "github_actions_organization_secret" "docker_hub_write_token" {
  secret_name     = "DOCKER_HUB_WRITE_TOKEN"
  plaintext_value = data.terraform_remote_state.docker_org_state.outputs.write_token
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.docker_hub_write_token
  id = "DOCKER_HUB_WRITE_TOKEN"
}

resource "github_actions_organization_secret" "CF_TURNSTILE_DEFAULT_INVISIBLE_SITE_KEY" {
  secret_name     = "CF_TURNSTILE_DEFAULT_INVISIBLE_SITE_KEY"
  plaintext_value = data.terraform_remote_state.cloudflare_account.outputs.turnstile_default_invisible_site_key
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.CF_TURNSTILE_DEFAULT_INVISIBLE_SITE_KEY
  id = "CF_TURNSTILE_DEFAULT_INVISIBLE_SITE_KEY"
}

data "onepassword_item" "digitalocean_api_token" {
  title = "DIGITALOCEAN_API_TOKEN"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "DIGTALOCEAN_API_TOKEN" {
  secret_name     = "DIGITALOCEAN_API_TOKEN"
  plaintext_value = data.onepassword_item.digitalocean_api_token.password
  visibility      = "all"
}

data "onepassword_item" "weblate_api_key" {
  title = "WEBLATE_API_KEY"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "WEBLATE_TOKEN" {
  secret_name     = "WEBLATE_TOKEN"
  plaintext_value = data.onepassword_item.weblate_api_key.password
  visibility      = "all"
}

data "onepassword_item" "vultr_api_token" {
  title = "VULTR_API_TOKEN"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "VULTR_API_TOKEN" {
  secret_name     = "VULTR_API_TOKEN"
  plaintext_value = data.onepassword_item.vultr_api_token.password
  visibility      = "all"
}

data "onepassword_item" "google_play_signing_key_jks" {
  title = "GOOGLE_PLAY_SIGNING_KEY_JKS"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "GOOGLE_PLAY_SIGNING_KEY_JKS" {
  secret_name     = "GOOGLE_PLAY_SIGNING_KEY_JKS"
  plaintext_value = data.onepassword_item.google_play_signing_key_jks.password
  visibility      = "all"
}

data "onepassword_item" "google_play_signing_key_alias" {
  title = "GOOGLE_PLAY_SIGNING_KEY_ALIAS"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "GOOGLE_PLAY_SIGNING_KEY_ALIAS" {
  secret_name     = "GOOGLE_PLAY_SIGNING_KEY_ALIAS"
  plaintext_value = data.onepassword_item.google_play_signing_key_alias.password
  visibility      = "all"
}

data "onepassword_item" "google_play_signing_key_password" {
  title = "GOOGLE_PLAY_SIGNING_KEY_PASSWORD"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "GOOGLE_PLAY_SIGNING_KEY_PASSWORD" {
  secret_name     = "GOOGLE_PLAY_SIGNING_KEY_PASSWORD"
  plaintext_value = data.onepassword_item.google_play_signing_key_password.password
  visibility      = "all"
}

data "onepassword_item" "google_play_signing_key_store_password" {
  title = "GOOGLE_PLAY_SIGNING_KEY_STORE_PASSWORD"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "GOOGLE_PLAY_SIGNING_KEY_STORE_PASSWORD" {
  secret_name     = "GOOGLE_PLAY_SIGNING_KEY_STORE_PASSWORD"
  plaintext_value = data.onepassword_item.google_play_signing_key_store_password.password
  visibility      = "all"
}

data "onepassword_item" "APP_STORE_CONNECT_API_KEY_ID" {
  title = "APP_STORE_CONNECT_API_KEY_ID"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "APP_STORE_CONNECT_API_KEY_ID" {
  secret_name     = "APP_STORE_CONNECT_API_KEY_ID"
  plaintext_value = data.onepassword_item.APP_STORE_CONNECT_API_KEY_ID.password
  visibility      = "all"
}

data "onepassword_item" "APP_STORE_CONNECT_API_KEY_ISSUER_ID" {
  title = "APP_STORE_CONNECT_API_KEY_ISSUER_ID"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "APP_STORE_CONNECT_API_KEY_ISSUER_ID" {
  secret_name     = "APP_STORE_CONNECT_API_KEY_ISSUER_ID"
  plaintext_value = data.onepassword_item.APP_STORE_CONNECT_API_KEY_ISSUER_ID.password
  visibility      = "all"
}

data "onepassword_item" "APP_STORE_CONNECT_API_KEY" {
  title = "APP_STORE_CONNECT_API_KEY"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "APP_STORE_CONNECT_API_KEY" {
  secret_name     = "APP_STORE_CONNECT_API_KEY"
  plaintext_value = data.onepassword_item.APP_STORE_CONNECT_API_KEY.password
  visibility      = "all"
}

data "onepassword_item" "IOS_CERTIFICATE_P12" {
  title = "IOS_CERTIFICATE_P12"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_CERTIFICATE_P12" {
  secret_name     = "IOS_CERTIFICATE_P12"
  plaintext_value = data.onepassword_item.IOS_CERTIFICATE_P12.password
  visibility      = "all"
}

data "onepassword_item" "IOS_CERTIFICATE_PASSWORD" {
  title = "IOS_CERTIFICATE_PASSWORD"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_CERTIFICATE_PASSWORD" {
  secret_name     = "IOS_CERTIFICATE_PASSWORD"
  plaintext_value = data.onepassword_item.IOS_CERTIFICATE_PASSWORD.password
  visibility      = "all"
}

data "onepassword_item" "IOS_PROVISIONING_PROFILE" {
  title = "IOS_PROVISIONING_PROFILE"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_PROVISIONING_PROFILE" {
  secret_name     = "IOS_PROVISIONING_PROFILE"
  plaintext_value = data.onepassword_item.IOS_PROVISIONING_PROFILE.password
  visibility      = "all"
}

data "onepassword_item" "FASTLANE_TEAM_ID" {
  title = "FASTLANE_TEAM_ID"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "FASTLANE_TEAM_ID" {
  secret_name     = "FASTLANE_TEAM_ID"
  plaintext_value = data.onepassword_item.FASTLANE_TEAM_ID.password
  visibility      = "all"
}

data "onepassword_item" "IOS_PROVISIONING_PROFILE_WIDGET_EXTENSION" {
  title = "IOS_PROVISIONING_PROFILE_WIDGET_EXTENSION"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_PROVISIONING_PROFILE_WIDGET_EXTENSION" {
  secret_name     = "IOS_PROVISIONING_PROFILE_WIDGET_EXTENSION"
  plaintext_value = data.onepassword_item.IOS_PROVISIONING_PROFILE_WIDGET_EXTENSION.password
  visibility      = "all"
}

data "onepassword_item" "IOS_PROVISIONING_PROFILE_SHARE_EXTENSION" {
  title = "IOS_PROVISIONING_PROFILE_SHARE_EXTENSION"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_PROVISIONING_PROFILE_SHARE_EXTENSION" {
  secret_name     = "IOS_PROVISIONING_PROFILE_SHARE_EXTENSION"
  plaintext_value = data.onepassword_item.IOS_PROVISIONING_PROFILE_SHARE_EXTENSION.password
  visibility      = "all"
}

data "onepassword_item" "IOS_DEVELOPMENT_PROVISIONING_PROFILE" {
  title = "IOS_DEVELOPMENT_PROVISIONING_PROFILE"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_DEVELOPMENT_PROVISIONING_PROFILE" {
  secret_name     = "IOS_DEVELOPMENT_PROVISIONING_PROFILE"
  plaintext_value = data.onepassword_item.IOS_DEVELOPMENT_PROVISIONING_PROFILE.password
  visibility      = "all"
}

data "onepassword_item" "IOS_DEVELOPMENT_PROVISIONING_PROFILE_SHARE_EXTENSION" {
  title = "IOS_DEVELOPMENT_PROVISIONING_PROFILE_SHARE_EXTENSION"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_DEVELOPMENT_PROVISIONING_PROFILE_SHARE_EXTENSION" {
  secret_name     = "IOS_DEVELOPMENT_PROVISIONING_PROFILE_SHARE_EXTENSION"
  plaintext_value = data.onepassword_item.IOS_DEVELOPMENT_PROVISIONING_PROFILE_SHARE_EXTENSION.password
  visibility      = "all"
}

data "onepassword_item" "IOS_DEVELOPMENT_PROVISIONING_PROFILE_WIDGET_EXTENSION" {
  title = "IOS_DEVELOPMENT_PROVISIONING_PROFILE_WIDGET_EXTENSION"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "IOS_DEVELOPMENT_PROVISIONING_PROFILE_WIDGET_EXTENSION" {
  secret_name     = "IOS_DEVELOPMENT_PROVISIONING_PROFILE_WIDGET_EXTENSION"
  plaintext_value = data.onepassword_item.IOS_DEVELOPMENT_PROVISIONING_PROFILE_WIDGET_EXTENSION.password
  visibility      = "all"
}

data "onepassword_item" "STATIC_BUCKET_NAME" {
  title = "STATIC_BUCKET_NAME"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "STATIC_BUCKET_NAME" {
  secret_name     = "STATIC_BUCKET_NAME"
  plaintext_value = data.onepassword_item.STATIC_BUCKET_NAME.password
  visibility      = "all"
}

data "onepassword_item" "STATIC_BUCKET_ENDPOINT" {
  title = "STATIC_BUCKET_ENDPOINT"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "STATIC_BUCKET_ENDPOINT" {
  secret_name     = "STATIC_BUCKET_ENDPOINT"
  plaintext_value = data.onepassword_item.STATIC_BUCKET_ENDPOINT.password
  visibility      = "all"
}

data "onepassword_item" "STATIC_BUCKET_KEY_ID" {
  title = "STATIC_BUCKET_KEY_ID"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "STATIC_BUCKET_KEY_ID" {
  secret_name     = "STATIC_BUCKET_KEY_ID"
  plaintext_value = data.onepassword_item.STATIC_BUCKET_KEY_ID.password
  visibility      = "all"
}

data "onepassword_item" "STATIC_BUCKET_KEY_SECRET" {
  title = "STATIC_BUCKET_KEY_SECRET"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "STATIC_BUCKET_KEY_SECRET" {
  secret_name     = "STATIC_BUCKET_KEY_SECRET"
  plaintext_value = data.onepassword_item.STATIC_BUCKET_KEY_SECRET.password
  visibility      = "all"
}

data "onepassword_item" "STATIC_BUCKET_REGION" {
  title = "STATIC_BUCKET_REGION"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "STATIC_BUCKET_REGION" {
  secret_name     = "STATIC_BUCKET_REGION"
  plaintext_value = data.onepassword_item.STATIC_BUCKET_REGION.password
  visibility      = "all"
}

data "onepassword_item" "OUTLINE_API_KEY" {
  title = "OUTLINE_API_KEY"
  vault = data.onepassword_vault.tf.name
}

resource "github_actions_organization_secret" "OUTLINE_API_KEY" {
  secret_name     = "OUTLINE_API_KEY"
  plaintext_value = data.onepassword_item.OUTLINE_API_KEY.password
  visibility      = "all"
}
