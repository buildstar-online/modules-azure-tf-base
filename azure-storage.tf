resource "random_pet" "vault_encryption" {
  length    = 2
  separator = "x"
}

resource "random_pet" "storage_acct" {
  length    = 2
  separator = "x"
}

resource "azurerm_storage_account" "storage_account" {
  name                      = random_pet.storage_acct.id
  resource_group_name       = azurerm_resource_group.resource_group.name
  location                  = azurerm_resource_group.resource_group.location
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
    ip_rules       = "${var.allowed_ips}"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.admin_identity.id
    ]
  }

  lifecycle {
    #prevent_destroy = true
    ignore_changes = [
      network_rules
    ]
  }

}

resource "azurerm_storage_container" "container" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.storage_account
  ]

}

resource "azurerm_role_assignment" "contributor" {
  count = length(local.all_users)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.resource_group.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.storage_account.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.all_users[count.index]
  
  depends_on = [
    azurerm_storage_container.container
  ]
}
