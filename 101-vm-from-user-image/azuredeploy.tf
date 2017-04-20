# Configure the Microsoft Azure Provider
# ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID environment variables assumed to be set 
# If environment variables not set, declare in azurerm provider
provider "azurerm" {}

variable "publicIPAddressType" {
  default = "Dynamic"
}

variable "osTypeMap" {
  description = "This is the OS that your VM will be running (value constraints)"
  type        = "map"

  default = {
    Windows = "windows"
    Linux   = "linux"
  }
}

variable "newOrExistingVnetMap" {
  description = "Select if this template needs a new VNet or will reference an existing VNet (value constraints)"
  type        = "map"

  default = {
    new      = "1"
    existing = "0"
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resourceGroupName}"
  location = "${var.resourceGroupLocation}"
}

resource "azurerm_virtual_network" "virtual_network1" {
  # Create only if New VNet is specified 
  count               = "${lookup(var.newOrExistingVnetMap, var.newOrExistingVnet)}"
  name                = "${var.newOrExistingVnetName}"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.resourceGroupLocation}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

resource "azurerm_subnet" "subnet1" {
  # Create only if New VNet is specified 
  count                = "${lookup(var.newOrExistingVnetMap, var.newOrExistingVnet)}"
  name                 = "${var.newOrExistingSubnetName}"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.virtual_network1.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_public_ip" "public_ip1" {
  name                         = "${var.customVmName}IP"
  location                     = "${var.resourceGroupLocation}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "${var.publicIPAddressType}"
  domain_name_label            = "${var.dnsLabelPrefix}"
}

resource "azurerm_network_interface" "network_interface1" {
  # Need Explicit Dependency for subnet as we don't reference the ID as it may already exist
  depends_on          = ["azurerm_subnet.subnet1"]
  name                = "${var.customVmName}Nic"
  location            = "${var.resourceGroupLocation}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_resource_group.resource_group.id}/providers/Microsoft.Network/virtualNetworks/${var.newOrExistingVnetName}/subnets/${var.newOrExistingSubnetName}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip1.id}"
  }
}

resource "azurerm_virtual_machine" "virtual_machine1" {
  name                  = "${var.customVmName}"
  location              = "${var.resourceGroupLocation}"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface1.id}"]
  vm_size               = "${var.vmSize}"

  os_profile {
    computer_name  = "${var.customVmName}"
    admin_username = "${var.adminUserName}"
    admin_password = "${var.adminPassword}"
  }

  storage_os_disk {
    name          = "${var.customVmName}-osDisk"
    image_uri     = "${var.osDiskVhdUri}"
    vhd_uri       = "https://${var.userImageStorageAccountName}.blob.core.windows.net/vhds/${var.customVmName}osdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "${var.osType}"
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "https://${var.userImageStorageAccountName}.blob.core.windows.net"
  }
}