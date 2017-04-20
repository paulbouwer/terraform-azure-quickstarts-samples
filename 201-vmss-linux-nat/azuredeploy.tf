#"The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version."
variable "ubuntu_os_version_map" {
  type = "map"

  default = {
    "14.04.4-LTS" = "14.04.4-LTS"
    "16.04.0-LTS" = "16.04.0-LTS"
  }
}

variable "config" {
  type = "map"

  default = {
    "address_prefix"       = "10.0.0.0/16"
    "subnet_prefix"        = "10.0.0.0/24"
    "nat_start_port"       = "50000"
    "nat_end_port"         = "50119"
    "nat_backend_port"     = "22"
    "os_type_publisher"    = "Canonical"
    "os_type_offer"        = "UbuntuServer"
    "os_type_version"      = "latest"
    "storage_account_type" = "Standard_LRS"
  }
}

# Unique name for the storage account
resource "random_id" "storage_account_name" {
  keepers = {
    # Generate a new id each time a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8
}

# Need to add resource group for Terraform
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

# Need a storage account until managed disks supported by terraform provider
resource "azurerm_storage_account" "storage_account1" {
  name                = "${random_id.storage_account_name.hex}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"
  account_type        = "${var.config["storage_account_type"]}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

# Need a storage container until managed disks supported by terraform provider
resource "azurerm_storage_container" "storage_container1" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.storage_account1.name}"
  container_access_type = "private"
}

resource "azurerm_public_ip" "public_ip1" {
  name                         = "${var.vmss_name}pip"
  location                     = "${var.resource_group_location}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${lower(var.vmss_name)}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

resource "azurerm_virtual_network" "virtual_network1" {
  name                = "${var.vmss_name}vnet"
  address_space       = ["${var.config["address_prefix"]}"]
  location            = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.vmss_name}subnet"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.virtual_network1.name}"
  address_prefix       = "${var.config["subnet_prefix"]}"
}

resource "azurerm_lb" "load_balancer1" {
  name                = "${var.vmss_name}lb"
  location            = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  frontend_ip_configuration {
    name                 = "loadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.public_ip1.id}"
  }

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool1" {
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer1.id}"
  name                = "${var.vmss_name}bepool"
}

# NAT Rule Load Balancer - using  mulitple NAT rules instead of a NATpool 
resource "azurerm_lb_nat_rule" "nat_rule1" {
  resource_group_name            = "${var.resource_group_location}"
  loadbalancer_id                = "${azurerm_lb.load_balancer1.id}"
  name                           = "Linux-SSH-VM-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "${count.index + var.config["nat_start_port"]}"
  backend_port                   = "${var.config["nat_backend_port"]}"
  frontend_ip_configuration_name = "loadBalancerFrontEnd"
  count                          = "${var.instance_count}"
}

resource "azurerm_virtual_machine_scale_set" "vm_scale_set1" {
  name                = "${var.vmss_name}"
  location            = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  upgrade_policy_mode = "Manual"
  overprovision       = "true"

  sku {
    name     = "${var.vm_sku}"
    tier     = "Standard"
    capacity = "${var.instance_count}"
  }

  network_profile {
    name    = "${var.vmss_name}nic"
    primary = true

    ip_configuration {
      name                                   = "${var.vmss_name}ipconfig"
      subnet_id                              = "${azurerm_subnet.subnet1.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.backend_address_pool1.id}"]
    }
  }

  storage_profile_os_disk {
    name           = "osdisk1"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    vhd_containers = ["${azurerm_storage_account.storage_account1.primary_blob_endpoint}${azurerm_storage_container.storage_container1.name}"]
  }

  storage_profile_image_reference {
    publisher = "${var.config["os_type_publisher"]}"
    offer     = "${var.config["os_type_offer"]}"
    sku       = "${lookup(var.ubuntu_os_version_map, var.ubuntu_os_version)}"
    version   = "${var.config["os_type_version"]}"
  }

  os_profile {
    computer_name_prefix = "${var.vmss_name}"
    admin_username       = "${var.admin_username}"
    admin_password       = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_sshkey}"
    }
  }

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}
