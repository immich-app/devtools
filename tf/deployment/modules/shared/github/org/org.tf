resource "github_organization_settings" "settings" {
  billing_email                                                = "billing@immich.app"
  company                                                      = "Immich"
  blog                                                         = "https://immich.app"
  email                                                        = ""
  twitter_username                                             = "immichapp"
  location                                                     = ""
  name                                                         = "Immich"
  description                                                  = "High-performance self-hosted photo and video management solution"
  has_organization_projects                                    = true
  has_repository_projects                                      = true
  default_repository_permission                                = "write"
  members_can_create_repositories                              = false
  members_can_create_public_repositories                       = false
  members_can_create_private_repositories                      = false
  members_can_create_internal_repositories                     = false
  members_can_create_pages                                     = false
  members_can_create_public_pages                              = false
  members_can_create_private_pages                             = false
  members_can_fork_private_repositories                        = false
  web_commit_signoff_required                                  = false
  advanced_security_enabled_for_new_repositories               = false
  dependabot_alerts_enabled_for_new_repositories               = false
  dependabot_security_updates_enabled_for_new_repositories     = false
  dependency_graph_enabled_for_new_repositories                = false
  secret_scanning_enabled_for_new_repositories                 = false
  secret_scanning_push_protection_enabled_for_new_repositories = false
}

import {
  id = 109746326
  to = github_organization_settings.settings
}
