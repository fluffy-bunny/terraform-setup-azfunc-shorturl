location_name = "eastus2"
resource_group_name = "rg-shorturl2"
storage_account_name = "stazfuncshorturl2"
plan_name = "plan-azfuncshorturl2"
app_insights_name = "appis-azfuncshorturl2"
func_name = "azfunc-shorturl2"

# export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name kv-tf-shorturl2 --query value -o tsv)