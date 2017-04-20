variable "boolean_map" {
  type = "map"

  default = {
    "true"  = "true"
    "false" = "false"
  }
}

variable "sku_name_map" {
  type = "map"

  default = {
    "standard" = "standard"
    "premium"  = "premium"
  }
}

resource "azurerm_resource_group" "quickstart" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

resource "azurerm_key_vault" "quickstart" {
  name                = "${var.keyvault_name}"
  location            = "${azurerm_resource_group.quickstart.location}"
  resource_group_name = "${azurerm_resource_group.quickstart.name}"

  sku {
    name = "${lookup(var.sku_name_map, var.sku_name)}"
  }

  tenant_id = "${var.keyvault_tenant_id}"

  access_policy {
    tenant_id = "${var.keyvault_tenant_id}"
    object_id = "${var.keyvault_object_id}"

    key_permissions    = "${var.keys_permissions}"
    secret_permissions = "${var.secrets_permissions}"
  }

  enabled_for_deployment          = "${lookup(var.boolean_map, var.enable_vault_for_deployment)}"
  enabled_for_disk_encryption     = "${lookup(var.boolean_map, var.enable_vault_for_disk_encryption)}"
  enabled_for_template_deployment = "${lookup(var.boolean_map, var.enabled_for_template_deployment)}"
}

output "vault_uri" {
  value = ["${azurerm_key_vault.quickstart.vault_uri}"]
}
