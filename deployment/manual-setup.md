# Manual Setup Steps

This lists all the steps required to manually setup the IAC deployments in Github Actions.

### Github Secrets

| Secret                      | Secret Type     | Description                                                                 | 
|-----------------------------|-----------------|-----------------------------------------------------------------------------|
| TF_APP_INSTALLATION_ID      | Organisation    | The installation ID of the Immich Github App                                |
| TF_APP_ID                   | Organisation    | The ID of the Immich Github App                                             |
| TF_APP_PEM_FILE             | Repo (devtools) | The contents of the PEM file for the Github App                             |
| TF_APP_GITHUB_OWNER         | Organisation    | The Github owner of the repository (immich-app)                             |
| CLOUDFLARE_API_TOKEN        | Repo (devtools) | The Cloudflare API token scoped to create new API keys                      |
| CLOUDFLARE_ACCOUNT_ID       | Organisation    | The Cloudflare account ID                                                   |
| TF_STATE_POSTGRES_CONN_STR  | Organisation    | The connection string for the Postgres database for Terraform state storage |
