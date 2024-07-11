variable "repositories" {
  type = list(object({
    name        = string
    description = string
    discussions = optional(bool)
    projects    = optional(bool)
    issues      = optional(bool)
    archived    = optional(bool)
  }))
  default = [
    {
      name        = "immich", description = "High performance self-hosted photo and video management solution.",
      discussions = true, projects = true
    },
    { name = "devtools", description = "Various tooling used by the Immich maintainer team" },
    {
      name = "static-pages", description = "Redirect urls to personal, hosted, instances of Immich.",
    },
    { name = "base-images", description = "Base images for Immich containers" },
    { name = "immich-charts", description = "Helm chart implementation of Immich" },
    { name = "discord-bot", description = "A Discord bot for the official @immich-app Discord" },
    { name = "demo", description = "This repo contains the setup for the demo instance at https://demo.immich.app/" },
    { name = "test-assets", description = "Test assets used for testing Immich. Contains various formats and codecs" },
    { name = ".github", description = ".github folder for the organisation level", issues = false }
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
  archived                  = coalesce(each.value.archived, false)
  auto_init                 = false
  delete_branch_on_merge    = true
  has_discussions           = coalesce(each.value.discussions, false)
  has_issues                = coalesce(each.value.issues, true)
  has_downloads             = true
  has_projects              = coalesce(each.value.projects, false)
  has_wiki                  = false
  vulnerability_alerts      = true
  homepage_url              = "https://immich.app"
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

import {
  to       = github_repository.repositories[each.value.name]
  id       = each.value.name
  for_each = { for repo in var.repositories : repo.name => repo }
}

resource "github_repository_ruleset" "main_ruleset" {
  for_each    = { for repo in var.repositories : repo.name => repo }
  repository  = each.value.name
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

  rules {
    creation         = true
    deletion         = true
    non_fast_forward = true
    pull_request {
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_approving_review_count   = 1
      required_review_thread_resolution = false
    }
    required_linear_history = true
    required_signatures     = false
    update                  = false
  }
}

moved {
  from = github_repository_ruleset.main_ruleset["my.immich.app"]
  to   = github_repository_ruleset.main_ruleset["static-pages"]
}

resource "github_repository_file" "default_files" {
  for_each = {
    for combination in flatten([
      for repo in var.repositories : [
        for file in fileset("${path.module}/repo-files", "**") : {
          repo = repo
          file = file
        }
        if !contains([".terragrunt-source-manifest", ".terragrunt-module-manifest"], file)
      ]
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

import {
  to = github_repository_file.default_files["static-pages/${each.value}"]
  id = "static-pages/${each.value}"
  for_each = {
    for file in fileset("${path.module}/repo-files", "**") : file => file
    if !contains([".terragrunt-source-manifest", ".terragrunt-module-manifest"], file)
  }
}

output "repositories" {
  value = {
    for repo in github_repository.repositories : repo.name => {
      name        = repo.name
      url         = repo.http_clone_url
      description = repo.description
    }
  }
}
