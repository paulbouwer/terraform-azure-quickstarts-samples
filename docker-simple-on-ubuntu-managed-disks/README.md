# Simple deployment of an Ubuntu VM with Docker (with managed disks)

This template allows you to deploy an Ubuntu VM with Docker installed via the Docker Extension. You can connect to the virtual machine via ssh and then run `docker` commands.

## Azure credentials for Terraform

To use this Azure Quickstart with Terraform, you will be required to set the following environment variables:
- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID

Read the README.md at the root of this repo for details on how to set up Azure Credentials for Terraform and how to get the values for each of the environment variables.

## Use Terraform

Once you have completed the pre-requisites and filled in all the variables in `terraform.tfvars`, then run the following command:

```
> terraform apply
```

## Pre-requisites

### Generate an ssh key

Generate an ssh key as follows:

```
> ssh-keygen -t rsa -b 2048 
```

Copy the contents of the following and place into the `admin_ssh_publickey` variable:

```
> cat ~/.ssh/id_rsa.pub
```

There are instructions for using PuTTY on Windows to generate your ssh keys [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows).

More information on using ssh with VMs in Azure:

- [How to create and use an SSH public and private key pair for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
- [How to Use SSH keys with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)

## Further information

For more information on Azure Virtual Machines and Virtual Machine Extensions:

- [Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Virtual Machine REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines)
- [Virtual Machine Extension REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/extensions)
- [Azure Managed Disks Overview](https://docs.microsoft.com/en-au/azure/storage/storage-managed-disks-overview)
- [GitHub - Docker VM Extension for Microsoft Azure](https://github.com/Azure/azure-docker-extension)
- [Create a Docker environment in Azure using the Docker VM extension](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/dockerextension)

---

This is based on the [docker-simple-on-ubuntu](https://github.com/Azure/azure-quickstart-templates/tree/master/docker-simple-on-ubuntu) Azure Quick Start Template.
