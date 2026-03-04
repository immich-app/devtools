locals {
  project_defaults = {
    authMethod   = "NONE"
    appType      = "WEB"
    redirectUris = []
    grantTypes   = ["AUTHORIZATION_CODE"]
    protocol     = "oidc"
    metadataUrl  = ""
  }
  projects_data = [
    {
      name         = "Grafana Monitoring Prod"
      roles        = [{ key = "GrafanaAdmin", grants_to = ["admin"] }, { key = "Editor", grants_to = ["team"] }]
      redirectUris = ["https://monitoring.immich.cloud/login/generic_oauth"]
    },
    {
      name         = "Grafana Monitoring Dev"
      roles        = [{ key = "GrafanaAdmin", grants_to = ["admin"] }, { key = "Editor", grants_to = ["team"] }]
      redirectUris = ["https://monitoring.dev.immich.cloud/login/generic_oauth"]
    },
    {
      name         = "Grafana Data Prod"
      roles        = [{ key = "GrafanaAdmin", grants_to = ["admin"] }, { key = "Editor", grants_to = ["team"] }]
      redirectUris = ["https://grafana.data.immich.cloud/login/generic_oauth"]
    },
    {
      name = "Outline"
      roles = [
        { key = "Leadership", grants_to = ["admin"] },
        { key = "Team", grants_to = ["team"] },
        { key = "Contributor", grants_to = ["contributor"] },
        { key = "Support Crew", grants_to = ["support"] }
      ]
      authMethod   = "BASIC"
      redirectUris = ["https://outline.immich.cloud/auth/oidc.callback"]
    },
    {
      name = "ContainerSSH"
      roles = [
        { key = "Granted", grants_to = ["admin", "team", "contributor"] }
      ]
      appType    = "NATIVE"
      grantTypes = ["DEVICE_CODE"]
    },
    {
      name         = "OAuth2 Proxy"
      roles        = [{ key = "Granted", grants_to = ["admin", "team"] }]
      redirectUris = ["https://oauth2-proxy.internal.immich.cloud/oauth2/callback"]
    },
    {
      name        = "OVHCloud"
      protocol    = "saml"
      roles       = [{ key = "ADMIN", grants_to = ["admin", "yucca"] }, { key = "DEFAULT", grants_to = ["team"] }]
      metadataUrl = "https://auth.eu.ovhcloud.com/sso/saml/sp/metadata.xml"
    }
  ]

  projects = [
    for project in local.projects_data : merge(local.project_defaults, project)
  ]

  oidc_projects = [
    for project in local.projects : project if project.protocol == "oidc"
  ]

  saml_projects = [
    for project in local.projects : project if project.protocol == "saml"
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
  for_each   = { for project in local.oidc_projects : project.name => project }
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

data "http" "saml_sp_metadata" {
  for_each = { for project in local.saml_projects : project.name => project }
  url      = each.value.metadataUrl
}

resource "zitadel_application_saml" "applications" {
  for_each     = { for project in local.saml_projects : project.name => project }
  name         = upper(replace(each.value.name, "/[^a-zA-Z0-9]/", "_"))
  org_id       = zitadel_org.immich.id
  project_id   = zitadel_project.projects[each.key].id
  metadata_xml = data.http.saml_sp_metadata[each.key].response_body
}
