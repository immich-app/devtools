# Terragrunt Deployment
This folder contains the Terragrunt configuration for deploying the [OpenTofu modules](./modules/).

## Quick start
To deploy the OpenTofu modules, follow these steps:

1. Install [tenv](https://github.com/tofuutils/tenv?tab=readme-ov-file#installation)
1. Find the versions for OpenTofu and Terragrunt we're currently using in the github action workflow [here](../.github/workflows/terragrunt.yml)
1. Install OpenTofu with `tenv tofu install ${version}` then run `tenv tofu use ${version}`
1. Install Terragrunt with `tenv terragrunt install ${version}` then run `tenv terragrunt use ${version}`
1. Set `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` and `TF_STATE_POSTGRES_CONN_STR` in your environment
1. Switch to the `deployment/modules` folder
1. Run `terragrunt run-all plan` to see what changes will be applied for your changes