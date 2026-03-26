data "zitadel_orgs" "zitadel" {
  name = "Zitadel"
}

data "zitadel_projects" "zitadel" {
  name   = "Zitadel"
  org_id = data.zitadel_orgs.zitadel.ids[0]
}

data "onepassword_vault" "tf" {
  name = "tf"
}
