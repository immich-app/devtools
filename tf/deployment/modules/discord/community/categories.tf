locals {
  category_order = [
    "immich",
    "community",
    "development",
    "team",
    "leadership",
    "third_parties",
    "off_topic",
    "voice",
    "archive"
  ]
}

resource "discord_category_channel" "immich" {
  name      = "Immich"
  server_id = discord_server.server.id
  position  = index(local.category_order, "immich")
}

import {
  id = 991478461862518825
  to = discord_category_channel.immich
}

resource "discord_category_channel" "community" {
  name      = "Community"
  server_id = discord_server.server.id
  position  = index(local.category_order, "community")
}

import {
  id = 1178365987410673705
  to = discord_category_channel.community
}

resource "discord_category_channel" "development" {
  name      = "Development"
  server_id = discord_server.server.id
  position  = index(local.category_order, "development")
}

import {
  id = 991478293922586675
  to = discord_category_channel.development
}

resource "discord_category_channel" "team" {
  name      = "Team"
  server_id = discord_server.server.id
  position  = index(local.category_order, "team")
}

import {
  id = 1330248426654531585
  to = discord_category_channel.team
}

resource "discord_category_channel" "leadership" {
  name      = "Leadership"
  server_id = discord_server.server.id
  position  = index(local.category_order, "leadership")
}

import {
  id = 1194044337760256020
  to = discord_category_channel.leadership
}

resource "discord_category_channel" "third_parties" {
  name      = "Third Parties"
  server_id = discord_server.server.id
  position  = index(local.category_order, "third_parties")
}

import {
  id = 1175153689682522122
  to = discord_category_channel.third_parties
}

resource "discord_category_channel" "off_topic" {
  name      = "Off Topic"
  server_id = discord_server.server.id
  position  = index(local.category_order, "off_topic")
}

import {
  id = 991643840131907594
  to = discord_category_channel.off_topic
}

resource "discord_category_channel" "voice" {
  name      = "Voice"
  server_id = discord_server.server.id
  position  = index(local.category_order, "voice")
}

import {
  id = 1315066626907046031
  to = discord_category_channel.voice
}

resource "discord_category_channel" "archive" {
  name      = "Archive"
  server_id = discord_server.server.id
  position  = index(local.category_order, "archive")
}

import {
  id = 1049707164178071636
  to = discord_category_channel.archive
}
