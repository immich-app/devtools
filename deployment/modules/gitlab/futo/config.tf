terraform {
  backend "pg" {
    schema_name = "prod_gitlab_futo"
  }
  required_version = "~> 1.7"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.1.0"
    }
  }
}
