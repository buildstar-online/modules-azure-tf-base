# modules-azure-tf-base
base resources for azure projects via terrform 

## Usage

```hcl
data "azurerm_client_config" "current" {
}

module "environment-base" {

  source = "github.com/cloudymax/modules-azure-tf-base"

  # Project settings
  environment      = "demo"
  location         = "westeurope"
  resource_group   = "demo-rg"
  subscription_id  = data.azurerm_client_config.current.subscription_id
  tenant_id        = data.azurerm_client_config.current.tenant_id
  runner_object_id = data.azurerm_client_config.current.object_id

  # Identities
  admin_identity = "admin-identity"

  # Virtual Network
  vnet_name          = "demo-net"
  vnet_address_space = ["10.0.0.0/16"]
  vnet_subnet_name   = "demo-subnet"
  subnet_prefixes    = ["10.0.1.0/16"]

  # Container Registry
  cr_name = "demo-registry"
  cr_sku  = "Basic"
  public_network_access_enabled = true

  # Storage
  storage_acct_name        = "demobucket"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  log_storage_tier         = "Hot"

  #KeyVault
  kv_name    = "demo-kv"
  kv_sku_name = "standard"

  # Firewall
  allowed_ips = ["some-ip"]
  admin_users = ["your-client-id"]
}
```

## Outputs

```hcl
output "kv_id" {
  value = azurerm_key_vault.key_vault.id
}
output "vnet_id" {
  value = azurerm_virtual_network.virtual_network.id
}
output "vnet_name" {
  value = azurerm_virtual_network.virtual_network.name
}
output "managed_identity" {
  value = azurerm_user_assigned_identity.admin_identity
}
output "managed_identity_name" {
  value = azurerm_user_assigned_identity.admin_identity.name
}
output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.admin_identity.client_id
}
output "managed_identity_id" {
  value = azurerm_user_assigned_identity.admin_identity.id
}
output "storage_account" {
  value = azurerm_storage_account.storage_account
}
output "log_contaier" {
  value = azurerm_storage_container.log_container
}
output "log_contaier_id" {
  value = azurerm_storage_container.log_container.id
}
output "log_contaier_sas" {
  value = data.azurerm_storage_account_blob_container_sas.website_logs_container_sas.sas
}
output "conatiner_registry" {
  value = azurerm_container_registry.container_registry
}
output "network_security_group" {
  value = azurerm_network_security_group.netsec_group
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_container_registry_webhook.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.admin_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_pet.container_registry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.identity](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.storage_acct](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.vault_encryption](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. | `string` | n/a | yes |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | logging storage account tier: Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_admin_identity"></a> [admin\_identity](#input\_admin\_identity) | Managed Identity created on deployment who will control the app services | `string` | n/a | yes |
| <a name="input_admin_users"></a> [admin\_users](#input\_admin\_users) | object\_id's for users /groups that will get admin access to things | `list(string)` | n/a | yes |
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | addresses allowed to access the infra | `list(string)` | n/a | yes |
| <a name="input_cr_sku"></a> [cr\_sku](#input\_cr\_sku) | SKU for the container registry: Basic, Standard and Premium. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | deployment environment - dev/staging/prod | `string` | `"dev"` | no |
| <a name="input_kv_sku_name"></a> [kv\_sku\_name](#input\_kv\_sku\_name) | SKU of the keyvault service: standard and premium | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | geo region where our items will be created | `string` | `"West Europe"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The time in days after which to remove blobs. A value of 0 means no retention. | `number` | `7` | no |
| <a name="input_log_storage_tier"></a> [log\_storage\_tier](#input\_log\_storage\_tier) | Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot | `string` | n/a | yes |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | decide if the contaier registry will be locked dow or not, only available on premium tier | `any` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | the azure resource group that will hold our stuff | `string` | n/a | yes |
| <a name="input_runner_object_id"></a> [runner\_object\_id](#input\_runner\_object\_id) | value | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | value | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | value | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | address space for the outer vnet | `list(any)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | name of the outer-most virtual network boundary | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_conatiner_registry"></a> [conatiner\_registry](#output\_conatiner\_registry) | n/a |
| <a name="output_contaier"></a> [contaier](#output\_contaier) | n/a |
| <a name="output_contaier_id"></a> [contaier\_id](#output\_contaier\_id) | n/a |
| <a name="output_container_registry_admin_password"></a> [container\_registry\_admin\_password](#output\_container\_registry\_admin\_password) | n/a |
| <a name="output_container_registry_admin_username"></a> [container\_registry\_admin\_username](#output\_container\_registry\_admin\_username) | n/a |
| <a name="output_container_registry_server_url"></a> [container\_registry\_server\_url](#output\_container\_registry\_server\_url) | n/a |
| <a name="output_kv_id"></a> [kv\_id](#output\_kv\_id) | n/a |
| <a name="output_managed_identity"></a> [managed\_identity](#output\_managed\_identity) | n/a |
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | n/a |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | n/a |
| <a name="output_managed_identity_name"></a> [managed\_identity\_name](#output\_managed\_identity\_name) | n/a |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
<!-- END_TF_DOCS -->
