resource "cloudflare_ruleset" "immich_app_redirects" {
  zone_id     = cloudflare_zone.immich_app.id
  name        = "Immich.app Redirects"
  description = "Redirects to immich.app"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://immich.app"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.host eq \"docs.immich.app\") or (http.host eq \"documentation.immich.app\")"
    description = "Redirect visitors going to docs links"
    enabled     = true
  }
}
