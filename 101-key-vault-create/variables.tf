variable "resource_group_name" {
  type        = "string"
  description = "Name of the azure resource group."
}

variable "resource_group_location" {
  type        = "string"
  description = "Location of the azure resource group."
}

variable "keyvault_name" {
  type        = "string"
  description = "Name of the key vault"
}

variable "keyvault_tenant_id" {
  type        = "string"
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get using 'az account show'."
}

variable "keyvault_object_id" {
  type        = "string"
  description = "The object ID of a service principal in the Azure Active Directory tenant for the key vault. Get using 'az ad sp show'."
}

variable "keys_permissions" {
  type        = "list"
  description = "Permissions to keys in the vault. Valid values are: all, create, import, update, get, list, delete, backup, restore, encrypt, decrypt, wrapkey, unwrapkey, sign, and verify."
}

variable "secrets_permissions" {
  type        = "list"
  description = "Permissions to secrets in the vault. Valid values are: all, get, set, list, and delete."
}

variable "sku_name" {
  type        = "string"
  default     = "standard"
  description = "SKU for the vault. Valid values are: standard, premium."
}

variable "enable_vault_for_deployment" {
  type        = "string"
  default     = "false"
  description = "Specifies if the vault is enabled for a VM deployment. Valid values are: true, false."
}

variable "enable_vault_for_disk_encryption" {
  type        = "string"
  default     = "false"
  description = "Specifies if the azure platform has access to the vault for enabling disk encryption scenarios. Valid values are: true, false."
}

variable "enabled_for_template_deployment" {
  type        = "string"
  default     = "true"
  description = "Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Valid values are: true, false."
}
