# modules-azure-tf-base
base resources for azure projects via terrform 

- Rsource-Group to hold all the resources for this environment
- Managed-Identity owned by the terraform runner w/ a randomly generated name
- An Azure Application owned by the Terraform runner
- An Azure Service-Principal assigned to the Azure Application and owned by the Terraform runner
- A Container-Registry with a randomized name assigned to a Managed Identity
- A Container-Registry Webhook (currently created but unused)
- An Azure Key-Vault with a random name
- An azure Key-Vault Access Policy for the Terraform runner, and Managed Identity
- An Azure Storage Account 
- An Azure Blob container
- Azure SAS urls (move to app service module)
- A rotating time resource for certificate expiration
- A top-level Virtual Network
- A Network Security-Group
- Inbound and Outbound security rules

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
