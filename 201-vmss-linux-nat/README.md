# Simple deployment of a VM Scale Set of Linux VMs behind a load balancer with NAT rules

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest patched version of Ubuntu Linux 16.04.0-LTS or 14.04.4-LTS. To connect from the load balancer to a VM in the scale set, you would go to the Azure Portal, find the load balancer of your scale set, examine the NAT rules, then connect using the NAT rule you want. For example, if there is a NAT rule on port 50000, you could use the following command to connect to that VM:

ssh -p 50000 {username}@{public-ip-address}

PARAMETER RESTRICTIONS
======================

vmssName must be 3-61 characters in length. It should also be globally unique across all of Azure. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 100 or less.

## Generate an ssh key

Generate an ssh key as follows:

```
> ssh-keygen -t rsa -b 2048 
```

Copy the contents of the following and place into the `admin_sshkey` variable:

```
> cat ~/.ssh/id_rsa.pub
```

There are instructions for using PuTTY on Windows to generate your ssh keys [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows).

More information:

- [How to create and use an SSH public and private key pair for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
- [How to Use SSH keys with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)

## Further information

For more information on Azure Virtual Machines and Virtual Machine Scale Sets:

- [Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Virtual Machine REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines)
- [Virtual Machine Scale Sets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets)

---

This is based on the [201-vmss-linux-nat](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-linux-nat) Azure Quick Start Template.