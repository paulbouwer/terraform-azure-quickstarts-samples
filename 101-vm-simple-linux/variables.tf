variable "resource_group_name" {
  description = "Name of the resource group container for all resources"
}

variable "resource_group_location" {
  description = "Azure region used for resource deployment"
}

variable "admin_username" {
  description = "User name for the Virtual Machine"
}

variable "admin_password" {
  description = "Password for the Virtual Machine."
}

variable "dns_label_prefix" {
  description = "Unique DNS Name for the Public IP used to access the Virtual Machine."
}

variable "ubuntu_os_version" {
  description = "The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
}

variable "admin_sshkey" {
  type        = "string"
  description = "SSH key for authentication to the Virtual Machines"
}
