# Terragrunt Deployment
This folder contains the Terragrunt configuration for deploying the [OpenTofu modules](./modules/).

## Quick start
To deploy the OpenTofu modules, follow these steps:

1. Install [tenv](https://github.com/tofuutils/tenv?tab=readme-ov-file#installation)
1. Find the versions for OpenTofu and Terragrunt we're currently using in the github action workflow [here](../.github/workflows/terragrunt.yml)
1. Install OpenTofu with `tenv tofu install ${version}` then run `tenv tofu use ${version}`
1. Install Terragrunt with `tenv terragrunt install ${version}` then run `tenv terragrunt use ${version}`
1. Install 1password cli `op`
1. Setup 1password cli with `op account add` and then `eval $(op signin)`
1. Run `op run --env-file=".env" -- terragrunt run-all plan` to see any terraform changes
