# Terraform - Azure Quickstarts Development Guidance

## Overview

This work aims to build reference Azure Terraform templates for the most common Azure deployment patterns. This will be realised through converting the Azure Resource Manager Quickstart Templates.

## Artifacts

### Azure Resource Manager Quickstart Templates

The Azure Quickstart Templates that this work is based on can be found at:

- [https://github.com/Azure/azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)

### Terraform Azure examples

The suggestion is to build out any azure terraform examples at:

- [https://github.com/hashicorp/terraform/tree/master/examples/azure](https://github.com/hashicorp/terraform/tree/master/examples/azure)

And these Azure Quickstart templates specifically at:

- [https://github.com/hashicorp/terraform/tree/master/examples/azure-quickstarts](https://github.com/hashicorp/terraform/tree/master/examples/azure-quiskstarts)


## Documentation

The top level `README.md` document specifies what authentication parameters are required by the Terraform AzureRM Provider and how to set them as environment variables. It details how to create a Service Principal and how to obtain the values from the Service Principal that the Terraform AzureRM Provider requires.

This file should be placed at the root of the azure quickstarts location. A suggestion would be:

- [https://github.com/hashicorp/terraform/tree/master/examples/azure-quickstarts/README.md](https://github.com/hashicorp/terraform/tree/master/examples/azure-quiskstarts/README.md)


## Guidance

The following guidance is provided in an effort to provide a consistent feel and approach to the quickstart templates.

Most of this guidance has been fully implemented in the following examples:

- docker-simple-on-ubuntu
- docker-simple-on-ubuntu-managed-disks

### File Naming and Layout
 
The following is the minimum list of files that should be present in each of the Azure Quickstart Templates:

```
azuredeploy.tf
provider.tf
README.tf
terraform.tfvars
variables.tf
```

The `README.md` file should consist of a description of the template and a reference to the Azure Resource Manager Quickstart Template that this is based on. See the [README](#readme-file) section for more details.

The `provider.tf` file is consistent across all of the quickstart templates. This provides a boilerplate approach to definining the Azure authentication details. They can be provided as environment variables out the box, but the `provider.tf` can be edited by the user to hard code them if they so wish.

The `azuredeploy.tf` file contains the actual resources that will be deployed. It should also contain the Azure Resource Group definition and any defined variables. The variables should be defined first and then the resources.

The `variables.tf` file should contain all the input parameters that the user can specify when deploying this terraform template. 

The `terraform.tfvars` file should contain all input parameters with values or hints such as `REPLACE_WITH_SSH_PUBLICKEY`, `REPLACE_WITH_UNIQUE_DNS_NAME` when requiring specific inputs from a user.

### README File

Look at the `docker-simple-on-ubuntu` folder for an example of a comprehensive `README.md` file.

This `README.md` file should copy the title and description of the template from the referenced Azure Resource Manager Quickstart Template. 

We also found it useful to have sections on how to configure Azure credentials for Terraform and how to use Terraform to deploy the templates available close to the actual templates. See the `Azure credentials for Terraform` and `Use Terraform` sections in the referenced `README.md` file.

After these sections, include any `pre-requisites` that are relevant. In the referenced `README.md` file, we added a section on how to create the ssh key. This ensures that the barrier to entry is low and everything the user needs to successfully deploy this template is provided.

We also found that it was useful to include references to the Azure Documentation for the services involved, the REST API Reference documentation, and any other relevant documentation. We also included a `This is based on` section at the end to provide a link to the original Azure Resource Manager Quickstart template so that a user could quickly compare the approaches to better understand. These details can be seen in the referenced `README.md` file.

### Naming Convention

All named items (variables, resources, etc) should be named all lowercase with words separated by an underscore. This is idiomatic Terraform.

Valid
```
vm_image_publisher
ubuntu_os_version_allowedvalues
```
Invalid
```
ubuntuOSVersion
newOrExistingVnetMap
```

### Parameters and Variables

Parameters that are provided by the user should be specified in the `variables.tf` file. Variables that are created and used as part of the template should be specified in the `azuredeploy.tf` file.

There may be value in explicitly specifying the type of the variables in the `variables.tf` file - we were undecided since most variables tended to be strings there.

When defining variables within the `azuredeploy.tf` file for internal template usage, a great pattern that we developed was to use a map. This helps to contain all the defined variables. You can use them by referencing them as `${var.config["variable_name"]}`, See the following example.

```
variable "config" {
  type = "map"

  default = {
    "namespace"                     = "docker"
    "vm_size"                       = "Standard_F1"
    "vm_image_publisher"            = "Canonical"
    "vm_image_offer"                = "UbuntuServer"
    "storage_account_type"          = "Standard_LRS"
    "network_address_prefix"        = "10.0.0.0/16"
    "network_subnet_prefix"         = "10.0.0.0/24"
    "network_public_ipaddress_type" = "Static"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                = "docker${random_id.storage_account_name.hex}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"

  account_type = "${var.config["storage_account_type"]}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}
```

### Resource Group

The resource group should be defined in the `azuredeploy.tf` file. If you have a complex template that requires a number of `.tf` files, then it may be worth explicitly placing the creation of the resource group in a `resourcegroup.tf` file.

### Required Azure Resource Manager Tags

All resources should have the following Azure Resource Manager tags attached:

```
  tags {
    Source = "Azure Quickstarts for Terraform"
  }
```

### Allowed Values

There is no native mechanism within Terraform to restrict a parameter to a list of allowed values, as you can do in ARM Templates. We developed the following approach to cater for this.

For a variable `ubuntu_os_version`, we create a map `ubuntu_os_version_allowedvalues` with the allowed values for that input parameter. Then we can ensure that we only accept those values by using as follows where we want the value `${var.ubuntu_os_version_allowedvalues[var.ubuntu_os_version]}`.

```
# variables.tf

variable "ubuntu_os_version" {
  type        = "string"
  description = "The Ubuntu version for deploying the Docker containers. This will pick a fully patched image of this given Ubuntu version. Allowed values: 16.04.0-LTS 16.10"
}

# azuredeploy.tf

variable "ubuntu_os_version_allowedvalues" {
  type = "map"

  default = {
    "16.04.0-LTS" = "16.04.0-LTS"
    "16.10"       = "16.10"
  }
}

resource "azurerm_virtual_machine" "virtual_machine" {
  name                = "${var.config["namespace"]}-vm"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"

  ...

  storage_image_reference {
    publisher = "${var.config["vm_image_publisher"]}"
    offer     = "${var.config["vm_image_offer"]}"
    sku       = "${var.ubuntu_os_version_allowedvalues[var.ubuntu_os_version]}"
    version   = "latest"
  }

  ...
}

```

### Enforcing Min and Max Values

No solution found.

### Secure Strings

No solution found to emulate secure string functionality in ARM Templates.

### Unique Names

A pattern we use often with ARM Templates is to generate a "unique" randmon string that can be appended to the name of  resources like a storage account that require a unique name for dns. This makes it simpler for the user in that they don't need to construct some uniqueness and provide it.

The approach below is how to implement this pattern in Terraform. This must be tied to the id of the Resource Group so that a new unique string is not created for each resource on updates. This approach ensures that a single unique string is retained for the deployment on creation of the Resource Group and maintained via Terraform's state management for all subsequent interactions with the resource.

The approach also shows how to use the unique string for naming resources.

```
# create the random unique string
resource "random_id" "unique_string" {
  keepers = {
    # Generate a new id each time a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8
}

# tie the random unique string to the name of the resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "${random_id.unique_string.keepers.resource_group}"
  location = "${var.resource_group_location}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

# use the unique string to name the resource
resource "azurerm_storage_account" "diagnostics_storage_account" {
  name                = "diag${random_id.unique_string.hex}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"

  account_type = "${var.config["storage_account_type"]}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

# use the same unique string to name another resource
resource "azurerm_storage_account" "disks_storage_account" {
  name                = "disk${random_id.unique_string.hex}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"

  account_type = "${var.config["storage_account_type"]}"

  tags {
    Source = "Azure Quickstarts for Terraform"
  }
}

```

### Conditional Resources

The following is a pattern that can be used to make the inclusion of a resource conditional. The count on the `azurerm_virtual_network.virtual_network` resource is used to ensure that it will only be created if the value of the `new_or_existing_vnet` user provided parameter is `1`.

```
# variables.tf

variable "new_or_existing_vnet" {
  description = "Select if this template needs a new VNet or will reference an existing VNet"
}

# azuredeploy.tf

variable "new_or_existing_vnet_allowedvalues" {
  description = "Select if this template needs a new VNet or will reference an existing VNet (value constraints)"
  type        = "map"

  default = {
    new      = "1"
    existing = "0"
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  # Create only if New VNet is specified 
  count               = "${var.new_or_existing_vnet_allowedvalues[var.new_or_existing_vnet]}"
  name                = "${var.newOrExistingVnetName}"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.resourceGroupLocation}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}
```

This approach only works on top-level resources. Azure Resource Manager has many sub/nested resources. Terraform does not have an approach or pattern available to conditionally include them. The example below shows that a blank `admin_password` field has to be supplied because we've specified ssh authentication. The Azure REST API would expect the `admin_password` field not be passed.

```
resource "azurerm_virtual_machine" "virtual_machine" {
  name                = "${var.config["namespace"]}-vm"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.resource_group_location}"

  ...

  os_profile {
    computer_name  = "${var.config["namespace"]}-vm"
    admin_username = "${var.admin_username}"
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_ssh_publickey}"
    }
  }
  ...
}
```

> **NOTE** 
>
> This example is easily solved with a blank value, but there are other examples such as having to exclude the entire `os_profile` section from the `azurerm_virtual_machine` resource when attaching an existing os disk. This does not seem to be possible without specifying another complete permutation of the top-level resource and leveraging the `count` field to include/exclude the resource.
>
> If you come across these examples, they need to be added to a list of issues for the specific azurerm provider. This can only be solved in code at the provider level. The offending nodes or fields need to be made *optional* in the schema of the azurerm provider and additional validate funcs added to include validation logic for the permutations. Once the azurerm provider is fixed, the template should be able to be cleanly presented without the requirement for multiple top-level permutations of the resource.


### Using template_files for ARM Templates

An example of using Terraform to deploy an existing ARM Template can be see in the following example:

- 101-hdinsight-spark-linux-vnet

The `azuredeploy.json` ARM Template can be included as-is and referenced as shown in the `azuredeploy.tf` file. There is currently no HDInsight azurerm provider, so the ARM Template is the only approach to deploy this resource via Terraform.

> **NOTE**
>
> Deploying ARM Templates violates the ability of Terraform to manage the state of the deployed resources under its control. It has no visibility into the opaque ARM Template. This method is probably best avoided, but may be necessary until the azurerm provider is feature complete.

### Conversion to use SSH Keys for Linux

A number of the Azure Resource Manager Quickstart Templates have used username/password authentication when creating Linux VMs. Most Linux users leverage SSH keys for authentication.

If the existing Azure Resource Manager Quickstart Template being converted does not use SSH, then convert it. A full example can be found in:

- docker-simple-on-ubuntu

### String Concatenation

There are a number of examples of string concatenation in the example:

```
  os_profile {
    computer_name  = "${var.config["namespace"]}-vm"
    admin_username = "${var.admin_username}"
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${var.admin_ssh_publickey}"
    }
  }

  storage_image_reference {
    publisher = "${var.config["vm_image_publisher"]}"
    offer     = "${var.config["vm_image_offer"]}"
    sku       = "${var.ubuntu_os_version_allowedvalues[var.ubuntu_os_version]}"
    version   = "latest"
  }

  storage_os_disk {
    name          = "osdisk1"
    vhd_uri       = "${azurerm_storage_account.storage_account.primary_blob_endpoint}vhds/osdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }
```

### Output Variables

Terraform output variables should be declared in the `azuredeploy.tf` file. We originally pulled them out into a separate `outputs.tf` file, but there were never a sufficient number of them to make it worthwhile. If you do have a large number of output variables and want to break them out, then place them in an `outputs.tf` file.

```

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.fqdn}"
}

```


