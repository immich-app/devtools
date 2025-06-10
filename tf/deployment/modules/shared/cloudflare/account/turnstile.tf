resource "cloudflare_turnstile_widget" "default_invisible" {
  account_id     = var.cloudflare_account_id
  name           = "default_invisible"
  bot_fight_mode = false
  domains        = [cloudflare_zone.immich_app.zone, cloudflare_zone.immich_cloud.zone, cloudflare_zone.immich_store.zone]
  mode           = "invisible"
  region         = "world"
}
