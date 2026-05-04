variable "repositories" {
  type = list(object({
    name                   = string
    description            = string
    url                    = optional(string)
    discussions            = optional(bool, false)
    projects               = optional(bool, false)
    issues                 = optional(bool, true)
    archived               = optional(bool, false)
    fork_source            = optional(string)
    collaborators          = optional(bool, false)
    require_codeowners     = optional(bool, false)
    license                = optional(string, "AGPL")
    collaborator_overrides = optional(map(string), {})
    visibility             = optional(string, "public")
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
      description = "Graphs and charts for Immich data",
      url         = "https://data.immich.app",
    },
    {
      name          = "ui",
      description   = "Svelte components for Immich",
      archived      = true,
      license       = "MIT",
      url           = "https://ui.immich.app",
      collaborators = true
    },
    {
      name        = "native_video_player",
      description = "A Flutter widget to play videos on iOS and Android using a native implementation.",
      fork_source = "albemala/native_video_player"
    },
    {
      name        = "justified-layout",
      license     = "MIT",
      description = "A blazingly fast implementation of the justified layout gallery view popularized by Flickr, written in Rust and exported to WebAssembly."
    },
    {
      name        = "ml-models",
      description = "Tools for exporting and benchmarking the ML models used by Immich."
    },
    {
      name        = "services",
      description = "Assortment of services, apis, webhooks, and other misc things."
    },
    {
      name                   = "one-click",
      description            = "One-Click deployment for Immich on various platforms.",
      license                = "MIT",
      collaborator_overrides = { "kennyfuto" : "maintain" }
    },
    {
      name        = "yucca-o11y",
      description = "o11y stack for yucca",
      license     = "SOURCE_FIRST"
    },
    {
      name        = "yucca",
      description = "Everything yucca",
      license     = "SOURCE_FIRST"
    },
    {
      name        = "restic-wrapper-ts",
      description = "TypeScript wrapper for the restic backup tool",
      license     = "MIT"
    },
    {
      name        = "sqlite-libs",
      description = "SQLite with extensions and query builders"
    },
    {
      name               = "pokedex",
      description        = "Pokedex is the Immich team's Kubernetes cluster for hardware testing, developer tools, and more"
      require_codeowners = true
    },
    {
      name          = "walkrs",
      license       = "MIT",
      description   = "Fast file tree walker for Node.js, built with ripgrep's ignore crate"
      collaborators = true
    },
    {
      name        = "packages",
      license     = "MIT",
      archived    = true,
      description = "A collection of libraries around the Immich project"
    },
    {
      name        = "yucca-slop",
      description = "yucca-slop",
      visibility  = "private"
    },
    {
      name        = "retro",
      description = "ISO generator for the Immich Retro Demo DVD",
      license     = "MIT"
    },
    {
      name        = "drift",
      description = "Drift is an easy to use, reactive, typesafe persistence library for Dart & Flutter.",
      fork_source = "simolus3/drift",
      url         = "https://pub.dev/packages/drift"
    }
  ]
}

import {
  id = "retro"
  to = github_repository.repositories["retro"]
}

import {
  id = "drift"
  to = github_repository.repositories["drift"]
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
  visibility                = each.value.visibility
  vulnerability_alerts      = !each.value.archived
  homepage_url              = coalesce(each.value.url, "https://immich.app")
  squash_merge_commit_title = "PR_TITLE"

  fork         = each.value.fork_source != null
  source_owner = each.value.fork_source != null ? split("/", each.value.fork_source)[0] : null
  source_repo  = each.value.fork_source != null ? split("/", each.value.fork_source)[1] : null

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
      if !coalesce(repo.archived, false)
    ]) : "${combination.repo.name}/${combination.file}" => combination
  }
  repository          = each.value.repo.name
  file                = each.value.file
  content             = file("${path.module}/repo-files/${each.value.file}")
  commit_message      = "chore: modify ${each.value.file}"
  overwrite_on_create = true

  depends_on = [github_repository.repositories]

  lifecycle {

    ignore_changes = [
      commit_message,
      commit_email,
      commit_author,
      overwrite_on_create
    ]
  }
}

resource "github_repository_file" "init_files" {
  for_each = {
    for combination in flatten([
      for repo in var.repositories : [
        for file in fileset("${path.module}/repo-init-files", "**") : {
          repo = repo
          file = file
        }
        # Ignore all .terragrunt files in any child directory
        if !can(regex(".*terragrunt.*", file))
      ]
      if !coalesce(repo.archived, false)
    ]) : "${combination.repo.name}/${combination.file}" => combination
  }
  repository          = each.value.repo.name
  file                = each.value.file
  content             = file("${path.module}/repo-init-files/${each.value.file}")
  commit_message      = "chore: create ${each.value.file}"
  overwrite_on_create = false

  depends_on = [github_repository.repositories]

  lifecycle {
    ignore_changes = [
      commit_message,
      commit_email,
      commit_author,
      overwrite_on_create,
      content
    ]
  }
}

import {
  id = "immich:renovate.json:"
  to = github_repository_file.init_files["immich/renovate.json"]
}

import {
  id = "devtools:renovate.json:"
  to = github_repository_file.init_files["devtools/renovate.json"]
}

import {
  id = "base-images:renovate.json:"
  to = github_repository_file.init_files["base-images/renovate.json"]
}

import {
  id = "yucca-o11y:renovate.json:"
  to = github_repository_file.init_files["yucca-o11y/renovate.json"]
}

import {
  id = "data.immich.app:renovate.json:"
  to = github_repository_file.init_files["data.immich.app/renovate.json"]
}

import {
  id = "static-pages:renovate.json:"
  to = github_repository_file.init_files["static-pages/renovate.json"]
}

import {
  id = "discord-bot:renovate.json:"
  to = github_repository_file.init_files["discord-bot/renovate.json"]
}

import {
  id = "yucca:renovate.json:"
  to = github_repository_file.init_files["yucca/renovate.json"]
}

import {
  id = "ml-models:renovate.json:"
  to = github_repository_file.init_files["ml-models/renovate.json"]
}

import {
  id = "immich-charts:renovate.json:"
  to = github_repository_file.init_files["immich-charts/renovate.json"]
}

import {
  id = "justified-layout:renovate.json:"
  to = github_repository_file.init_files["justified-layout/renovate.json"]
}

import {
  id = "sqlite-libs:renovate.json:"
  to = github_repository_file.init_files["sqlite-libs/renovate.json"]
}

import {
  id = "restic-wrapper-ts:renovate.json:"
  to = github_repository_file.init_files["restic-wrapper-ts/renovate.json"]
}

resource "github_repository_file" "license_files" {
  for_each = {
    for repo in var.repositories : repo.name => repo
    if repo.fork_source == null && !coalesce(repo.archived, false)
  }
  repository          = each.value.name
  file                = "LICENSE"
  content             = file("${path.module}/license-files/${each.value.license}.txt")
  commit_message      = "chore: modify LICENSE to ${each.value.license}"
  overwrite_on_create = true

  depends_on = [github_repository.repositories]

  lifecycle {
    ignore_changes = [
      commit_message,
      commit_email,
      commit_author,
      overwrite_on_create
    ]
  }
}
