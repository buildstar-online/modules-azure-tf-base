locals {
  generated_users = tolist(["${azurerm_user_assigned_identity.admin_identity.principal_id}", "${var.runner_object_id}"])
  all_users       = concat(var.admin_users, local.generated_users)
}
