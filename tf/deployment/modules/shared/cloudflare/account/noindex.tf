resource "cloudflare_ruleset" "immich_app_preview_noindex" {
  zone_id     = cloudflare_zone.immich_app.id
  name        = "Preview noindex"
  description = "Add X-Robots-Tag: noindex to non-production (preview) Pages deployments"
  kind        = "zone"
  phase       = "http_response_headers_transform"

  rules {
    action = "rewrite"
    action_parameters {
      headers {
        name      = "X-Robots-Tag"
        operation = "set"
        value     = "noindex"
      }
    }
    expression  = "ends_with(http.host, \".dev.immich.app\") or ends_with(http.host, \".preview.immich.app\") or ends_with(http.host, \".archive.immich.app\")"
    description = "noindex preview hostnames"
    enabled     = true
  }
}
