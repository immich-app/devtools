// Explicitly link every external identity (GitHub and GitLab) to its ZITADEL
// user, keyed on the external id from users.json. This makes login fully
// deterministic — ZITADEL matches the pre-created link by external id, so we
// rely on neither username nor email auto-linking (GitHub usernames can be
// renamed; GitLab usernames/emails differ from the GitHub-derived account).
//
// The provider has no IdP-link resource, so each link is a built-in
// terraform_data resource (one per user+IdP, tracked in state) that shells out
// to the management API: create adds the link, destroy removes it, and a change
// to the identifying fields replaces it. Already-existing links (e.g. created by
// a prior auto-link) are treated as success, so this is safe to apply over
// users who have already logged in. Everything the destroy provisioner needs
// lives in `input` (destroy-time provisioners may only reference `self`).
locals {
  github_idp_links = {
    for key, user in local.github_users : "${key}/github" => {
      user_id          = zitadel_human_user.users[key].id
      idp_id           = zitadel_idp_github.github.id
      external_user_id = tostring(user.github.id)
      user_name        = user.github.username
    }
  }

  gitlab_idp_links = merge(
    # dual-identity users (keyed by github id) that also carry a gitlab block
    {
      for key, user in local.github_users : "${key}/gitlab" => {
        user_id          = zitadel_human_user.users[key].id
        idp_id           = zitadel_idp_gitlab_self_hosted.gitlab.id
        external_user_id = tostring(user.gitlab.id)
        user_name        = user.gitlab.username
      }
      if try(user.gitlab.id, null) != null
    },
    # gitlab-only users (keyed by gitlab-<id>)
    {
      for key, user in local.gitlab_only_users : "${key}/gitlab" => {
        user_id          = zitadel_human_user.users[key].id
        idp_id           = zitadel_idp_gitlab_self_hosted.gitlab.id
        external_user_id = tostring(user.gitlab.id)
        user_name        = user.gitlab.username
      }
    },
  )

  idp_links = merge(local.github_idp_links, local.gitlab_idp_links)
}

resource "terraform_data" "idp_link" {
  for_each = local.idp_links

  input = {
    user_id          = each.value.user_id
    idp_id           = each.value.idp_id
    external_user_id = each.value.external_user_id
    user_name        = each.value.user_name
    domain           = var.futo_zitadel_base_domain
    token            = zitadel_personal_access_token.zitadel_actions.token
  }

  # Replace (unlink + relink) if any identifying field changes.
  triggers_replace = [each.value.user_id, each.value.idp_id, each.value.external_user_id, each.value.user_name]

  provisioner "local-exec" {
    command = "${path.module}/scripts/idp-link.sh create"
    environment = {
      ZITADEL_DOMAIN   = self.input.domain
      ZITADEL_TOKEN    = self.input.token
      USER_ID          = self.input.user_id
      IDP_ID           = self.input.idp_id
      EXTERNAL_USER_ID = self.input.external_user_id
      USER_NAME        = self.input.user_name
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/idp-link.sh delete"
    environment = {
      ZITADEL_DOMAIN   = self.input.domain
      ZITADEL_TOKEN    = self.input.token
      USER_ID          = self.input.user_id
      IDP_ID           = self.input.idp_id
      EXTERNAL_USER_ID = self.input.external_user_id
    }
  }
}
