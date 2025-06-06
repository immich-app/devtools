resource "zitadel_action" "map_github_oauth" {
  org_id          = zitadel_org.immich.id
  name            = "mapGitHubOAuth"
  script          = <<-EOT
    let logger = require("zitadel/log");
    let { fetch } = require("zitadel/http");

    async function mapGitHubOAuth(ctx, api) {
      if (ctx.v1.externalUser.externalIdpId !== "${zitadel_idp_github.github.id}") {
        return;
      }

      try {
        const response = fetch('https://api.github.com/user/emails', {
          method: 'GET',
          headers: {
            'Authorization': 'Bearer ' + ctx.accessToken,
            'Accept': 'application/vnd.github.v3+json'
          }
        });

        if (!response.status == 200) {
          logger.error("Failed to fetch GitHub emails, status: " + response.status + ", body: " + response.text());
          return;
        }

        const emails = response.json();

        let primaryEmail = null;
        const primaryEmailObject = emails.find(email => email.primary);
        if (primaryEmailObject) {
          primaryEmail = primaryEmailObject.email;
        }

        if (primaryEmail) {
          api.setEmail(primaryEmail);
          api.setEmailVerified(true);
        } else {
          logger.warn("No primary email found in GitHub response for user: " + ctx.v1.externalUser.human.displayName);
        }

      } catch (error) {
        logger.error("Error fetching or processing GitHub emails: " + error.toString());
      }

      let firstName = ctx.v1.providerInfo.login;
      let lastName = " ";

      const nameParts = ctx.v1.providerInfo.name.trim().split(" ");
      if (nameParts.length > 0 && nameParts[0].length > 0) {
        firstName = nameParts[0];
      }
      if (nameParts.length > 1) {
        lastName = nameParts.slice(1).join(" ");
      }

      api.setFirstName(firstName);
      api.setLastName(lastName);
    }
    EOT
  allowed_to_fail = true
  timeout         = "10s"
}

resource "zitadel_trigger_actions" "map_github_oauth" {
  org_id       = zitadel_org.immich.id
  action_ids   = [zitadel_action.map_github_oauth.id]
  trigger_type = "TRIGGER_TYPE_POST_AUTHENTICATION"
  flow_type    = "FLOW_TYPE_EXTERNAL_AUTHENTICATION"
}

resource "zitadel_action" "map_roles" {
  org_id          = zitadel_org.immich.id
  name            = "mapRoles"
  script          = <<-EOT
    const logger = require('zitadel/log');

    function mapRoles(ctx, api) {
      logger.info('help');
      if (ctx.v1.user.grants == undefined || ctx.v1.user.grants.count == 0) {
        return;
      }

      // I want to use named capture groups but apparently they aren't supported
      const projectId = Object.keys(ctx.v1.claims).map((claim) => claim.match(/urn:zitadel:iam:org:project:(?<projectId>\d+):roles/)?.[1]).filter(Boolean).at(0);

      if (!projectId) {
        return;
      }


      const grants = ctx.v1.user.grants.grants.filter((grant) => grant.projectId === projectId);
      const roles = grants.map(({ roles }) => roles);

      if (roles.length === 1) {
        api.v1.claims.setClaim('role', String(roles[0]));
        return;
      }

      if (roles.length > 1) {
        api.v1.claims.setClaim('roles', roles)
      }
    }
    EOT
  allowed_to_fail = false
  timeout         = "10s"
}

resource "zitadel_trigger_actions" "map_roles" {
  org_id       = zitadel_org.immich.id
  action_ids   = [zitadel_action.map_roles.id]
  trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
}
