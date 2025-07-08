resource "github_organization_ruleset" "tag_restrictions" {
  name        = "Pushing Tags Restrictions"
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 912027 # Immich Tofu Integration App
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 977022 # Immich Push-o-Matic Integration App
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    creation = true
    deletion = true
    update   = true
  }
}

resource "github_organization_ruleset" "org_required_checks" {
  name        = "Org Required Checks"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 912027 # Immich Tofu Integration App
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 977022 # Immich Push-o-Matic Integration App
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    required_status_checks {
      required_check {
        context = "Check for Team/Admin Review / check-approval"
      }
    }
  }
}
