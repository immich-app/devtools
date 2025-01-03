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
    expression  = "(http.host eq \"docs.immich.app\") or (http.host eq \"documentation.immich.app\") or (http.host eq \"www.immich.app\")"
    description = "Redirect visitors going to docs or www"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://discord.gg/cHD2af9DbA"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.host eq \"discord.immich.app\")"
    description = "Redirect discord.immich.app to discord"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://play.google.com/store/apps/details?id=app.alextran.immich"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host wildcard \"get.immich.app\" and http.request.uri.path matches \"^/android$\")"
    description = "Redirect get.immich.app/android to the Play Store"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://apps.apple.com/us/app/immich/id1613945652"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host wildcard \"get.immich.app\" and http.request.uri.path matches \"^/ios$\")"
    description = "Redirect get.immich.app/ios to the App Store"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://f-droid.org/en/packages/app.alextran.immich/"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host wildcard \"get.immich.app\" and http.request.uri.path matches \"^/fdroid$\")"
    description = "Redirect get.immich.app/fdroid to the F-Droid"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://play.google.com/store/apps/details?id=app.alextran.immich"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host wildcard \"get.immich.app\" and http.request.uri.path matches \"^/$\" and http.user_agent wildcard r\"*Android*\")"
    description = "Redirect get.immich.app android users to the Play Store"
    enabled     = true
  }

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 307
        target_url {
          value = "https://apps.apple.com/us/app/immich/id1613945652"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host wildcard \"get.immich.app\" and http.request.uri.path matches \"^/$\")"
    description = "Redirect get.immich.app iPhone users to the App Store"
    enabled     = true
  }
}

resource "cloudflare_ruleset" "immich_cloud_redirects" {
  zone_id     = cloudflare_zone.immich_cloud.id
  name        = "Immich.cloud to immich.app redirects"
  description = "Redirects immich.cloud to immich.app"
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
    expression  = "(http.host eq \"www.immich.cloud\") or (http.host eq \"immich.cloud\")"
    description = "Redirect visitors going to immich.cloud links"
    enabled     = true
  }
}
