resource "discord_server" "server" {
  name                          = var.env == "prod" ? "FUTO" : "FUTO ${title(var.env)}"
  region                        = "us-west"
  default_message_notifications = 1
  explicit_content_filter       = 2
  verification_level            = 1
}

import {
  id = var.futo_discord_server_id
  to = discord_server.server
}
