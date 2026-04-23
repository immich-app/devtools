locals {
  project_defaults = {
    authMethod             = "NONE"
    appType                = "WEB"
    redirectUris           = []
    postLogoutRedirectUris = []
    grantTypes             = ["AUTHORIZATION_CODE"]
    devMode                = false
  }

  // Customer-facing OIDC applications. Add an entry per FUTO product that
  // authenticates end users against this instance. Each product gets its own
  // project + OIDC client; client_id / client_secret are written to 1Password.
  //
  // The "Dev Test" app is only created in the dev environment. It has dev_mode
  // enabled (so http://localhost redirects are allowed) and carries a confidential
  // client_secret that lands in 1Password, suitable for wiring up a local
  // product build or manual testing with oauth2-proxy / curl / pstmn.
  projects_data = concat(
    var.env == "dev" ? [
      {
        name       = "Dev Test"
        authMethod = "BASIC"
        appType    = "WEB"
        grantTypes = ["AUTHORIZATION_CODE", "REFRESH_TOKEN"]
        redirectUris = [
          "http://localhost:3000/auth/callback",
          "http://localhost:5173/auth/callback",
          "http://localhost:8080/auth/callback",
          "http://127.0.0.1:3000/auth/callback",
          "http://localhost:5173/api/auth/oidc/callback",
          "http://localhost:22676/api/yucca/auth/oidc/callback",
        ]
        postLogoutRedirectUris = [
          "http://localhost:3000/",
          "http://localhost:5173/",
          "http://localhost:8080/",
          "http://127.0.0.1:3000/",
        ]
        devMode = true
      }
    ] : [],
    [
      // Real products here. Append as each product onboards.
    ]
  )

  projects = [
    for project in local.projects_data : merge(local.project_defaults, project)
  ]
}

resource "zitadel_project" "projects" {
  for_each               = { for project in local.projects : project.name => project }
  name                   = each.value.name
  org_id                 = zitadel_org.customers.id
  project_role_check     = false
  project_role_assertion = true
  has_project_check      = false
}

resource "zitadel_application_oidc" "applications" {
  for_each   = { for project in local.projects : project.name => project }
  name       = upper(replace(each.value.name, "/[^a-zA-Z0-9]/", "_"))
  org_id     = zitadel_org.customers.id
  project_id = zitadel_project.projects[each.key].id

  redirect_uris             = each.value.redirectUris
  post_logout_redirect_uris = each.value.postLogoutRedirectUris
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = [for grant_type in each.value.grantTypes : "OIDC_GRANT_TYPE_${grant_type}"]
  app_type                  = "OIDC_APP_TYPE_${each.value.appType}"
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_${each.value.authMethod}"
  access_token_type         = "OIDC_TOKEN_TYPE_JWT"
  dev_mode                  = each.value.devMode

  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  access_token_role_assertion = true
}
