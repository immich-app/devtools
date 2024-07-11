data "gitlab_group" "immich" {
  full_path = "immich"
}

resource "gitlab_project" "immich-app-mirrors" {
  name         = replace(each.value.name, "/\\.(.*)/", "dot-$1")
  namespace_id = data.gitlab_group.immich.id
  description  = each.value.description
  import_url   = each.value.url
  mirror       = true

  visibility_level = "public"


  for_each = {
    for repo in data.terraform_remote_state.github_state.outputs.repositories : repo.name => repo
  }
}
