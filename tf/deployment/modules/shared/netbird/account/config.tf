terraform {
  backend "pg" {
    schema_name = "prod_netbird_account"
  }
  required_version = "~> 1.7"

  required_providers {
    # Fork of netbirdio/netbird that fixes the group resources<->map conversion
    # crash so a group attached to a network_resource can be updated (e.g. to
    # set peers). Published to the Terraform Registry, so the source is
    # fully-qualified to fetch from registry.terraform.io rather than OpenTofu's
    # default registry. See futo-org/terraform-provider-netbird.
    netbird = {
      source  = "registry.terraform.io/futo-org/netbird"
      version = "1.0.2"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}
