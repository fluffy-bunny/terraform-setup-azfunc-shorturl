![fluffy-bunny-banner](https://raw.githubusercontent.com/fluffy-bunny/static-assets/master/fluffy-bunny-banner.png)  
# terraform-setup-azfunc-guidgen
This project terraforms azure by providing everything needed to deploy the azFunc-guidgen function.  

## Prerequisite
We need to add 5 things to the project->Settings->secrets;
### `"AZURE_CREDENTIALS"`
Follow the instructions here;
[github action azure login](https://github.com/Azure/login)  

## Setup you service principal
```bash
az login
az account set --subscription="<SUBSCRIPTION_ID>"
az ad sp create-for-rbac --name sp-terraform-subscription-<SUBSCRIPTION_ID>  --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>  -sdk-auth"  

produces.

{
  "clientId": "<GUID>",
  "clientSecret": "<GUID>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>",
  (...)
}
  
```
This will create a service principal, which you can see in AD App Registration that has the rights to create resources in the subscription.  


Take the data that you needed for `"AZURE_CREDENTIALS"` and add the following secrets;  
```
ARM_CLIENT_ID = <GUID>
ARM_CLIENT_SECRET = <GUID>
ARM_SUBSCRIPTION_ID = <GUID>
ARM_TENANT_ID = <GUID>
```

# Secrets

We should have 5 secrets in `"project->settings->secrets"`;  
`"AZURE_CREDENTIALS"`
`"ARM_CLIENT_ID"`
`"ARM_CLIENT_SECRET"`
`"ARM_SUBSCRIPTION_ID"`
`"ARM_TENANT_ID"`




[project secrets](https://github.com/fluffy-bunny/terraform-azure-backend-setup/settings/secrets)
to use azure login, please follow the following instructions.
[github action azure login](https://github.com/Azure/login)  

As of this writing I have not been able to get terraform to work with azure managed identity.  Service Principals auth works.

The github actions need to set the following environment variables, which are all secrets;
```bash
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

By convention, add the secrets you produced by creating the rbac service principal and add them like you added AZURE_CREDENTIALS.
```
ARM_CLIENT_ID = <GUID>
ARM_CLIENT_SECRET = <GUID>
ARM_SUBSCRIPTION_ID = <GUID>
ARM_TENANT_ID = <GUID>
```  

The [github action](.github/workflows/terraform-tstate-setup.yml) will pull this data from secrets and export it to environment variables.  

# Azure Storage of Terraform State.  

following the [tutorial](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend) I have create a [bash script](bash/setup.sh) which gets called from our [github action](.github/workflows/terraform-tstate-setup.yml)  

The end state of the script produces a Key Vault and StorageAccount in a resource group dedicated to just terraform.  
the following script is then run downstream so that terraform knows where to store state;  
```
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-<FRIENDLY_NAME> --query value -o tsv)
```
For terraform to run the following exports need to be present;  
```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name ${{ env.VAULT_NAME }} --query value -o tsv)
export ARM_CLIENT_ID='${{secrets.ARM_CLIENT_ID}}'
export ARM_CLIENT_SECRET='${{secrets.ARM_CLIENT_SECRET}}'
export ARM_SUBSCRIPTION_ID=$(az account show --query id | xargs)
export ARM_TENANT_ID=$(az account show --query tenantId | xargs)
```
since I do an Azure Login, I just pull some of the ID's based on the current logged in principal.  


## Reference
[terraform service_principal_client_secret](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)  
[github action azure login](https://github.com/Azure/login)  


