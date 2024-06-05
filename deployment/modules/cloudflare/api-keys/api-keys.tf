data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "terraform_cloudflare_account" {
  name = "terraform_cloudflare_account"
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Pages Write"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone Settings Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Dynamic URL Redirects Write"],
      data.cloudflare_api_token_permission_groups.all.account["Workers R2 Storage Write"]
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
  name = "terraform_cloudflare_docs"
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
  name = "terraform_cloudflare_pages_upload"
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

resource "cloudflare_api_token" "mich_cloudflare_r2_token" {
  name = "mich_r2_token"
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.r2["Workers R2 Storage Bucket Item Write"]
    ]
    resources = {
      "com.cloudflare.edge.r2.bucket.*" = "*"
    }
  }
  condition {
    request_ip {
      in = local.mich_cidrs
    }
  }
}

output "mich_cloudflare_r2_token_id" {
  value     = cloudflare_api_token.mich_cloudflare_r2_token.id
  sensitive = true
}

output "mich_cloudflare_r2_token_value" {
  value     = cloudflare_api_token.mich_cloudflare_r2_token.value
  sensitive = true
}