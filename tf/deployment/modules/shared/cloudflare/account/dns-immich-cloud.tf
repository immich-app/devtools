resource "cloudflare_record" "immich_cloud_aaaa_root" {
  name    = "immich.cloud"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_cname_star_dot_root" {
  name    = "*.immich.cloud"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mich.immich.cloud"
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_a_mich" {
  name    = "mich"
  proxied = false
  ttl     = 1
  type    = "A"
  content = local.mich_ip
  zone_id = cloudflare_zone.immich_cloud.id
}

resource "cloudflare_record" "immich_cloud_txt_google_site_verification" {
  name    = "immich.cloud"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"google-site-verification=vz4uoHrM2u53jPk2suBueakblxEYZljvAlu-WH8Rl1I\""
  zone_id = cloudflare_zone.immich_cloud.id
}
