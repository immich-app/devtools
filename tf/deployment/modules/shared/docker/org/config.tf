terraform {
  backend "pg" {
    schema_name = "prod_docker_org"
  }
  required_version = "~> 1.7"

  required_providers {
    docker = {
      source  = "registry.terraform.io/docker/docker"
      version = "0.4.3"
    }
  }
}
