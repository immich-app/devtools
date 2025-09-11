# Domain Module

This Terraform module generates fully qualified domain names (FQDNs) based on application name, environment, stage, and base domain parameters.

## Variables

- `app_name` - The application name (special value "root" creates no subdomain)
- `env` - The environment (e.g., "prod", "dev", "staging")
- `stage` - Optional stage identifier (e.g., "pr-55", "feature-123")
- `domain` - The base domain (must be a root domain like "immich.app", not a subdomain)

## Domain Generation Rules

1. **Stage**: Only included if set (not empty string)
2. **Environment**: Excluded for "prod", included for all others
3. **App Name**: 
   - Value "root" results in no subdomain
   - Non-alphanumeric characters are replaced with hyphens
   - Any other value becomes a subdomain

## Output

The module outputs a single value `fqdn` containing the generated domain.

## Examples

### Production Environment

```hcl
# Production root domain
module "prod_root" {
  app_name = "root"
  env      = "prod"
  stage    = ""
  domain   = "immich.app"
}
# Output: immich.app

# Production with app subdomain
module "prod_buy" {
  app_name = "buy"
  env      = "prod"
  stage    = ""
  domain   = "immich.app"
}
# Output: buy.immich.app

# Production with complex app name
module "prod_my_app" {
  app_name = "my_app"
  env      = "prod"
  stage    = ""
  domain   = "immich.app"
}
# Output: my-app.immich.app
```

### Development Environment

```hcl
# Development root domain
module "dev_root" {
  app_name = "root"
  env      = "dev"
  stage    = ""
  domain   = "immich.app"
}
# Output: dev.immich.app

# Development with app subdomain
module "dev_buy" {
  app_name = "buy"
  env      = "dev"
  stage    = ""
  domain   = "immich.app"
}
# Output: buy.dev.immich.app

# Development with API subdomain
module "dev_api" {
  app_name = "api"
  env      = "dev"
  stage    = ""
  domain   = "immich.app"
}
# Output: api.dev.immich.app
```

### Staging Environment

```hcl
# Staging root domain
module "staging_root" {
  app_name = "root"
  env      = "staging"
  stage    = ""
  domain   = "immich.app"
}
# Output: staging.immich.app

# Staging with app subdomain
module "staging_app" {
  app_name = "dashboard"
  env      = "staging"
  stage    = ""
  domain   = "immich.app"
}
# Output: dashboard.staging.immich.app
```

### With Stage Identifiers (e.g., Pull Requests)

```hcl
# PR in development
module "pr_dev" {
  app_name = "buy"
  env      = "dev"
  stage    = "pr-55"
  domain   = "immich.app"
}
# Output: buy.pr-55.dev.immich.app

# Feature branch in development
module "feature_dev" {
  app_name = "api"
  env      = "dev"
  stage    = "feature-123"
  domain   = "immich.app"
}
# Output: api.feature-123.dev.immich.app

# PR with root app in development
module "pr_root_dev" {
  app_name = "root"
  env      = "dev"
  stage    = "pr-100"
  domain   = "immich.app"
}
# Output: pr-100.dev.immich.app

# Stage in production (rare but possible)
module "stage_prod" {
  app_name = "buy"
  env      = "prod"
  stage    = "canary"
  domain   = "immich.app"
}
# Output: buy.canary.immich.app
```

### Different Base Domains

```hcl
# Using different TLD
module "example_com" {
  app_name = "shop"
  env      = "prod"
  stage    = ""
  domain   = "example.com"
}
# Output: shop.example.com

# Using a different domain
module "different_domain" {
  app_name = "api"
  env      = "dev"
  stage    = ""
  domain   = "mycompany.io"
}
# Output: api.dev.mycompany.io
```

### Edge Cases

```hcl
# App name with special characters (converted to hyphens)
module "special_chars" {
  app_name = "my.app@2024"
  env      = "dev"
  stage    = ""
  domain   = "immich.app"
}
# Output: my-app-2024.dev.immich.app

# All parameters set
module "full_example" {
  app_name = "admin"
  env      = "staging"
  stage    = "rc-1"
  domain   = "immich.app"
}
# Output: admin.rc-1.staging.immich.app

# Minimal production (root + prod = base domain only)
module "minimal" {
  app_name = "root"
  env      = "prod"
  stage    = ""
  domain   = "immich.app"
}
# Output: immich.app
```

## Domain Structure Pattern

The general pattern for domain generation is:
```
[app_name].[stage].[env].[domain]
```

Where:
- `app_name` is omitted if "root"
- `stage` is omitted if empty
- `env` is omitted if "prod"
- Non-alphanumeric characters in app_name are replaced with hyphens