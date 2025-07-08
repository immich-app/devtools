removed {
  from = github_organization_webhook.bot
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_repository_webhook.previews
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_repository_webhook.fluxcd
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.cloudflare_api_token_pages_upload
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.tiles_r2_kv_token_id
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.tiles_r2_kv_token_value
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.tiles_r2_kv_token_hashed_value
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.push_o_matic_app_id
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.push_o_matic_app_installation_id
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.push_o_matic_app_key
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.npm_read_token
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.npm_write_token
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.docker_hub_read_token
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.docker_hub_write_token
  lifecycle {
    destroy = false
  }
}

removed {
  from = github_actions_organization_secret.CF_TURNSTILE_DEFAULT_INVISIBLE_SITE_KEY
  lifecycle {
    destroy = false
  }
}
