resource "random_pet" "container_registry" {
  length    = 2
  separator = "x"
}

resource "azurerm_container_registry" "container_registry" {
  name                          = "registryx${random_pet.container_registry.id}"
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = azurerm_resource_group.resource_group.location
  sku                           = var.cr_sku
  public_network_access_enabled = var.public_network_access_enabled
  admin_enabled                 = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.admin_identity.id
    ]
  }
}

resource "azurerm_container_registry_webhook" "webhook" {
  name                = "mywebhook"
  resource_group_name = azurerm_resource_group.resource_group.name
  registry_name       = azurerm_container_registry.container_registry.name
  location            = azurerm_resource_group.resource_group.location

  # Specifies the service URI for the Webhook to post notifications.
  service_uri = "https://mywebhookreceiver.example/mytag"

  status = "enabled"

  # Specifies the scope of repositories that can trigger an event. For example, foo:* means events for all tags under repository foo. foo:bar means events for 'foo:bar' only. foo is equivalent to foo:latest. Empty means all events
  scope = ""

  # A list of actions that trigger the Webhook to post notifications. At least one action needs to be specified. Valid values are: push, delete, quarantine, chart_push, chart_delete
  actions = ["push"]
}


/*
resource "azurerm_role_assignment" "pull" {
  count = length(local.all_users)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.resource_group.name}/providers/Microsoft.ContainerRegistry/registries/${azurerm_container_registry.container_registry.name}"
  role_definition_name = "AcrPull"
  principal_id         = local.all_users[count.index]
  depends_on = [
    azurerm_container_registry.container_registry
  ]
}

resource "azurerm_role_assignment" "push" {
  count = length(local.all_users)
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.resource_group.name}/providers/Microsoft.ContainerRegistry/registries/${azurerm_container_registry.container_registry.name}"
  role_definition_name = "AcrPush"
  principal_id         = local.all_users[count.index]
  depends_on = [
    azurerm_container_registry.container_registry
  ]
}
*/

