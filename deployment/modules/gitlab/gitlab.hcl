locals {
  futo_gitlab_token = get_env("FUTO_GITLAB_TOKEN")
}

inputs = {
  futo_gitlab_token = local.futo_gitlab_token
}
