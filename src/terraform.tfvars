location_name = "eastus2"
resource_group_name = "rg-githubactions"
storage_account_name = "stazfuncguidgen"
plan_name = "plan-azfuncguidgen"
app_insights_name = "appis-azfuncguidgen"
func_name = "azfunc-guidgen"

# export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-githubactions --query value -o tsv)