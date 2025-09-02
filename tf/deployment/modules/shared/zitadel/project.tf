locals {
  project_defaults = {
    authMethod   = "NONE"
    appType      = "WEB"
    redirectUris = []
    grantTypes   = ["AUTHORIZATION_CODE"]
  }
  projects_data = [
    {
      name         = "Grafana Monitoring Prod"
      roles        = { "GrafanaAdmin" : ["admin"], "Editor" : ["team"] }
      redirectUris = ["https://monitoring.immich.cloud/login/generic_oauth"]
    },
    {
      name         = "Grafana Monitoring Dev"
      roles        = { "GrafanaAdmin" : ["admin"], "Editor" : ["team"] }
      redirectUris = ["https://monitoring.dev.immich.cloud/login/generic_oauth"]
    },
    {
      name         = "Grafana Data Prod"
      roles        = { "GrafanaAdmin" : ["admin"], "Editor" : ["team"] }
      redirectUris = ["https://grafana.data.immich.cloud/login/generic_oauth"]
    },
    {
      name         = "Outline"
      roles        = { "Leadership" : ["admin"], "Team" : ["team"], "Contributor" : ["contributor"], "Support Crew" : ["support"] }
      authMethod   = "BASIC"
      redirectUris = ["https://outline.immich.cloud/auth/oidc.callback"]
    },
    {
      name = "ContainerSSH"
      roles = {
        "Granted" : ["admin", "team", "contributor"]
      }
      appType    = "NATIVE"
      grantTypes = ["DEVICE_CODE"]
    },
    {
      name         = "OAuth2 Proxy"
      roles        = { "Granted" : ["admin", "team"] }
      redirectUris = ["https://oauth2-proxy.internal.immich.cloud/oauth2/callback"]
    }
  ]

  projects = [
    for project in local.projects_data : merge(local.project_defaults, project)
  ]
}

resource "zitadel_project" "projects" {
  for_each               = { for project in local.projects : project.name => project }
  name                   = each.value.name
  org_id                 = zitadel_org.immich.id
  project_role_check     = true
  project_role_assertion = true
  has_project_check      = false
}

resource "zitadel_application_oidc" "applications" {
  for_each   = { for project in local.projects : project.name => project }
  name       = upper(replace(each.value.name, "/[^a-zA-Z0-9]/", "_"))
  org_id     = zitadel_org.immich.id
  project_id = zitadel_project.projects[each.key].id

  redirect_uris    = each.value.redirectUris
  response_types   = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types      = [for grant_type in each.value.grantTypes : "OIDC_GRANT_TYPE_${grant_type}"]
  app_type         = "OIDC_APP_TYPE_${each.value.appType}"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_${each.value.authMethod}"
}

resource "onepassword_item" "application_client_id" {
  for_each = { for application in zitadel_application_oidc.applications : application.name => application }

  vault    = data.onepassword_vault.tf.uuid
  title    = "ZITADEL_OAUTH_CLIENT_ID_${each.value.name}"
  category = "password"

  password = each.value.client_id
}

resource "onepassword_item" "application_client_secret" {
  for_each = {
    for application in zitadel_application_oidc.applications : application.name => application
    if application.auth_method_type != "OIDC_AUTH_METHOD_TYPE_NONE"
  }

  vault    = data.onepassword_vault.tf.uuid
  title    = "ZITADEL_OAUTH_CLIENT_SECRET_${each.value.name}"
  category = "password"

  password = each.value.client_secret
}
