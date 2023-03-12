resource "random_pet" "this" {
  length    = 2
  separator = "x"
}

resource "azurerm_key_vault" "this" {
  name                       = random_pet.this.id
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  tenant_id                  = azurerm_user_assigned_identity.admin_identity.tenant_id
  sku_name                   = var.kv_sku_name
  soft_delete_retention_days = 7
  purge_protection_enabled   = false


  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ips
  }

  depends_on = [
    random_pet.this
  ]
  lifecycle {
    ignore_changes = [
      network_acls
    ]
  }
}

locals {
  generated_users = tolist(["${azurerm_user_assigned_identity.admin_identity.principal_id}", "${var.runner_object_id}"])
  all_users       = concat(var.admin_users, local.generated_users)
}

resource "azurerm_key_vault_access_policy" "admins" {
  count = length(local.all_users)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = local.all_users[count.index]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]

  key_permissions = [
    "Get", "Backup", "Create", "Delete", "Decrypt", "Encrypt", "List", "Import", "Purge", "Recover", "Restore", "Sign", "Update", "Verify"
  ]

  secret_permissions = [
    "Get", "Delete", "Backup", "List", "Set", "Purge", "Restore", "Recover"
  ]

}
