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

data "onepassword_item" "npm_read_token" {
  title = "npm-read-token"
  vault = data.onepassword_vault.github.name
}

resource "github_actions_organization_secret" "npm_read_token" {
  secret_name     = "NPM_READ_TOKEN"
  plaintext_value = data.onepassword_item.npm_read_token.credential
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.npm_read_token
  id = "NPM_READ_TOKEN"
}

data "onepassword_item" "npm_write_token" {
  title = "npm-write-token"
  vault = data.onepassword_vault.github.name
}

resource "github_actions_organization_secret" "npm_write_token" {
  secret_name     = "NPM_TOKEN"
  plaintext_value = data.onepassword_item.npm_write_token.credential
  visibility      = "all"
}

import {
  to = github_actions_organization_secret.npm_write_token
  id = "NPM_TOKEN"
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
