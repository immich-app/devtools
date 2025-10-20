resource "cloudflare_record" "immich_build_aaaa_root" {
  name    = "immich.build"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_build.id
}

resource "cloudflare_record" "immich_build_aaaa_www" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "AAAA"
  content = "100::"
  zone_id = cloudflare_zone.immich_build.id
}

resource "cloudflare_record" "immich_build_cname_star_dot_root" {
  name    = "*.immich.build"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "mich.immich.build"
  zone_id = cloudflare_zone.immich_build.id
}

resource "cloudflare_record" "immich_build_a_mich" {
  name    = "mich"
  proxied = false
  ttl     = 1
  type    = "A"
  content = local.mich_ip
  zone_id = cloudflare_zone.immich_build.id
}

resource "cloudflare_record" "immich_build_txt_google_site_verification" {
  name    = "immich.build"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"google-site-verification=tf_nTykp5S6m2oEp7R01w5AjajH5uM8cheVPmySmqcY\""
  zone_id = cloudflare_zone.immich_build.id
}
