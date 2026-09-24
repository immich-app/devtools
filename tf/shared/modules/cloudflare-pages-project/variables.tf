variable "cloudflare_api_token" {}
variable "cloudflare_account_id" {}

variable "env" {}
variable "app_name" {}
variable "domain" {
  default = "immich.app"
}

# app_name for the analytics site's hostname (it only accepts beacons from that host), if different
variable "analytics_app_name" {
  default = null
}
