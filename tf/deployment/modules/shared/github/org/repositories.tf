variable "repositories" {
  type = list(object({
    name               = string
    description        = string
    url                = optional(string)
    discussions        = optional(bool, false)
    projects           = optional(bool, false)
    issues             = optional(bool, true)
    archived           = optional(bool, false)
    fork               = optional(bool, false)
    collaborators      = optional(bool, false)
    require_codeowners = optional(bool, false)
    license            = optional(string, "AGPL")
  }))
  default = [
    {
      name          = "immich", description = "High performance self-hosted photo and video management solution.",
      discussions   = true,
      projects      = true,
      collaborators = true
    },
    {
      name               = "devtools",
      description        = "Various tooling used by the Immich maintainer team",
      require_codeowners = true
    },
    {
      name          = "static-pages",
      description   = "Redirect urls to personal, hosted, instances of Immich.",
      url           = "https://buy.immich.app",
      collaborators = true
    },
    {
      name        = "base-images",
      description = "Base images for Immich containers"
    },
    {
      name        = "immich-charts",
      description = "Helm chart implementation of Immich"
    },
    {
      name        = "discord-bot",
      description = "A Discord bot for the official @immich-app Discord"
    },
    {
      name        = "demo",
      description = "This repo contains the setup for the demo instance at https://demo.immich.app/"
      url         = "https://demo.immich.app",
      archived    = true
    },
    {
      name          = "test-assets",
      description   = "Test assets used for testing Immich. Contains various formats and codecs",
      collaborators = true
    },
    {
      name        = ".github",
      description = ".github folder for the organisation level",
      issues      = false
    },
    {
      name        = "geoshenanigans",
      description = "Geospatial shenanigans, reverse geocoding, map tiling, and maybe more..."
    },
    {
      name        = "data.immich.app",
      description = "Graphs and charts for Immich data"
      url         = "https://data.immich.app",
    },
    {
      name          = "ui",
      description   = "Svelte components for Immich"
      url           = "https://ui.immich.app",
      collaborators = true
    },
    {
      name        = "sql-tools",
      description = "A collection of tools and utilities to help manage SQL migrations"
    },
    {
      name        = "native_video_player",
      description = "A Flutter widget to play videos on iOS and Android using a native implementation.",
      fork        = true
    },
    {
      name        = "justified-layout",
      description = "A blazingly fast implementation of justified layout, a gallery view popularized by Flickr, written in rust and exported to WASM."
    },
    {
      name        = "ml-models",
      description = "Tools for exporting and benchmarking the ML models used by Immich."
    },
    {
      name        = "one-click",
      description = "One-Click deployment for Immich on various platforms.",
      license     = "MIT"
    }
  ]
}

resource "github_repository" "repositories" {
  for_each                  = { for repo in var.repositories : repo.name => repo }
  name                      = each.value.name
  description               = each.value.description
  allow_auto_merge          = true
  allow_merge_commit        = false
  allow_rebase_merge        = false
  allow_squash_merge        = true
  allow_update_branch       = true
  archived                  = each.value.archived
  auto_init                 = false
  delete_branch_on_merge    = true
  has_discussions           = each.value.discussions
  has_issues                = each.value.issues
  has_downloads             = true
  has_projects              = each.value.projects
  has_wiki                  = false
  vulnerability_alerts      = !each.value.archived
  homepage_url              = coalesce(each.value.url, "https://immich.app")
  squash_merge_commit_title = "PR_TITLE"

  lifecycle {
    ignore_changes = [
      # Provider bug when merge commit is disabled, it can't update these
      merge_commit_message,
      merge_commit_title,
      # Pages will be managed manually for now
      pages
    ]
  }
}

resource "github_repository_ruleset" "main_ruleset" {
  for_each    = { for repo in var.repositories : repo.name => repo }
  repository  = github_repository.repositories[each.value.name].name
  name        = "Main Protection"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
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
    creation         = true
    deletion         = true
    non_fast_forward = true
    pull_request {
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = each.value.require_codeowners
      require_last_push_approval        = false
      required_approving_review_count   = 1
      required_review_thread_resolution = false
    }
    required_linear_history = true
    required_signatures     = false
    update                  = false
  }
}

resource "github_repository_ruleset" "custom_rules" {
  for_each    = { for repo in var.repositories : repo.name => repo }
  repository  = github_repository.repositories[each.value.name].name
  name        = "Custom Rules"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
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

  rules {}

  lifecycle {
    ignore_changes = [rules]
  }
}


resource "github_repository_file" "default_files" {
  for_each = {
    for combination in flatten([
      for repo in var.repositories : [
        for file in fileset("${path.module}/repo-files", "**") : {
          repo = repo
          file = file
        }
        # Ignore all .terragrunt files in any child directory
        if !can(regex(".*terragrunt.*", file))
      ]
      if !coalesce(repo.fork, false) && !coalesce(repo.archived, false)
    ]) : "${combination.repo.name}/${combination.file}" => combination
  }
  repository          = each.value.repo.name
  file                = each.value.file
  content             = file("${path.module}/repo-files/${each.value.file}")
  commit_message      = "chore: modify ${each.value.file}"
  overwrite_on_create = true

  lifecycle {

    ignore_changes = [
      commit_message,
      commit_email,
      commit_author,
      overwrite_on_create
    ]
  }
}

resource "github_repository_file" "license_files" {
  for_each = {
    for repo in var.repositories : repo.name => repo
    if !coalesce(repo.fork, false) && !coalesce(repo.archived, false)
  }
  repository          = each.value.name
  file                = "LICENSE"
  content             = file("${path.module}/license-files/${each.value.license}.txt")
  commit_message      = "chore: modify LICENSE to ${each.value.license}"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      commit_message,
      commit_email,
      commit_author,
      overwrite_on_create
    ]
  }
}

import {
  to = github_repository_file.license_files["${each.value.name}"]
  id = "${each.value.name}/LICENSE"
  for_each = {
    for repo in var.repositories : repo.name => repo
    if !coalesce(repo.fork, false) && !coalesce(repo.archived, false) && repo.name != "one-click"
  }
}


import {
  to = github_repository.repositories["native_video_player"]
  id = "native_video_player"
}

# import {
#   to = github_repository_file.default_files["static-pages/${each.value}"]
#   id = "static-pages/${each.value}"
#   for_each = {
#     for file in fileset("${path.module}/repo-files", "**") : file => file
#     # FIXME find a better solution
#     if !contains([".terragrunt-source-manifest", ".terragrunt-module-manifest", ".github/.terragrunt-source-manifest", ".github/.terragrunt-module-manifest"], file)
#   }
# }
