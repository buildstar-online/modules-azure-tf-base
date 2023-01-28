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

## Getting Started

1. Install Azure CLI

   ```bash
   brew update && \
   brew install azure-cli
   ```

2. Install Bitwarden CLI

   ```bash
   brew install bitwarden-cli
   ```

3. Login

   ```bash
   # Authorize the Azure CLI
   az login
   ```

4. Create your service principle

  - Create a service account to represent your digital self and use that to run terraform locally.

  - In production, a unique service account should be created for running and applying the terraform jobs,
and it should create smaller accounts at instantiation to run the infra it provisions.

  - 'Owner' level access is required because we need to create role assignments. This may potentially be
scoped down to 'User Access Administrator' + 'Contributor'

      ```bash
      SUBSCRIPTION=$(az account show --query id --output tsv)
      SP_NAME="myserviceaccount"

      az ad sp create-for-rbac --sdk-auth \
        --display-name="${SP_NAME}" \
        --role="Owner" \
        --scopes="/subscriptions/$SUBSCRIPTION"
      ```

  - Add the resulting data to KeePassXC / Bitwarden for now. You will need it again multiple times.

___


5. Set Azure Active Directory Permissions

This is required in order to set AD roles in terraform.

  - Login to https://portal.azure.com/
  - Navigate to `Azure Active Directory`
  - Select `Roles and administrators` from the left-side menu
  - Click `Application administrator`
  - Click `Add Assignments`
  - Search for your service accounts name
  - Repeat for `Application Developer` Role.

___

6. Log-in as the service principle or user.

- we will use this account to create the terraform state bucket.

```bash
  az login --service-principal \
    --username $(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="clientId") |.value') \
    --password $(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="clientSecret") |.value') \
    --tenant $(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="tenantId") |.value')
```

____

7. Create the Terraform state bucket

  - All Azure Storage Accounts are encrypted by default using Microsoft Managed Keys
    ```bash
    export SUBSCRIPTION=$(az account show --query id --output ts    export KIND="StorageV2"
    export LOCATION="westeurope"
    export RG_NAME="example-tf-state"
    export STORAGE_NAME="examplertfstatebucket"
    export STORAGE_SKU="Standard_RAGRS"
    export CONTAINER_NAME="exampletfstate"

    az group create \
      -l="${LOCATION}" \
      -n="${RG_NAME}"

    az storage account create \
      --name="${STORAGE_NAME}" \
      --resource-group="${RG_NAME}" \
      --location="${LOCATION}" \
      --sku="${STORAGE_SKU}" \
      --kind="${KIND}"

    az storage account encryption-scope create \
      --account-name="${STORAGE_NAME}"  \
      --key-source Microsoft.Storage \
      --name="tfencryption"\
      --resource-group="${RG_NAME}" \
      --subscription="${SUBSCRIPTION}"

    az storage container create \
        --name="${CONTAINER_NAME}" \
        --account-name="${STORAGE_NAME}" \
        --resource-group="${RG_NAME}" \
        --default-encryption-scope="tfencryption" \
        --prevent-encryption-scope-override="true" \
        --auth-mode="login" \
        --fail-on-exist \
        --public-access="off"
    ```
___

8. Run terraform

```bash
docker run --platform linux/amd64 -it \
-e ARM_CLIENT_ID=$(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="clientId") |.value') \
-e ARM_CLIENT_SECRET=$(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="clientSecret") |.value') \
-e ARM_SUBSCRIPTION_ID=$(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="subscriptionId") |.value') \
-e ARM_TENANT_ID=$(bw get item lab-admin-robot |jq -r '.fields[] |select(.name=="tenantId") |.value') \
-v $(pwd):/terraform -w /terraform \
hashicorp/terraform init
```


## Usage

```hcl
module "environment-base" {

  source = "github.com/cloudymax/modules-azure-tf-base"
  
  # Project settings
  environment      = each.value
  location         = var.location
  resource_group   = "${var.resource_group}-${each.value}"
  subscription_id  = data.azurerm_client_config.current.subscription_id
  tenant_id        = data.azurerm_client_config.current.tenant_id
  runner_object_id = data.azurerm_client_config.current.object_id

  # Identities
  admin_identity = "${each.value}-identity"

  # Virtual Network
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  vnet_subnet_name   = var.vnet_subnet_name
  subnet_prefixes    = ["10.0.1.0/16"]

  # Container Registry
  cr_name = var.cr_name
  cr_sku  = var.cr_sku[each.key]

  # Storage
  storage_acct_name        = var.storage_acct_name
  account_tier             = var.account_tier[each.key]
  account_replication_type = var.account_replication_type
  log_storage_tier         = var.log_storage_tier

  #KeyVault
  kv_name    = "${each.value}-${var.kv_name}"
  kv_sku_ame = var.kv_sku_name[each.key]
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
