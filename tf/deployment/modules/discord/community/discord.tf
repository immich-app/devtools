resource "discord_server" "server" {
  name                          = "Immich"
  region                        = "us-west"
  default_message_notifications = 1
  explicit_content_filter       = 2
  verification_level            = 1
}

import {
  id = "979116623879368755"
  to = discord_server.server
}
