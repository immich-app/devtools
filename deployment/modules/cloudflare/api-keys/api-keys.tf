data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "terraform_cloudflare_account" {
  name = "terraform"
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Pages Write"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone Settings Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Dynamic URL Redirects Write"],
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }
}

output "terraform_key_cloudflare_account" {
  value     = cloudflare_api_token.terraform_cloudflare_account.value
  sensitive = true
}

resource "cloudflare_api_token" "terraform_cloudflare_docs" {
  name = "terraform"
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Pages Write"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }
}

output "terraform_key_cloudflare_docs" {
  value     = cloudflare_api_token.terraform_cloudflare_account.value
  sensitive = true
}


resource "cloudflare_api_token" "terraform_cloudflare_pages_upload" {
  name = "terraform"
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Pages Write"],
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }
}

output "terraform_key_cloudflare_pages_upload" {
  value     = cloudflare_api_token.terraform_cloudflare_account.value
  sensitive = true
}
