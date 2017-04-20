# Create 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set

This template will deploy 2 new VMs (along with a new VNet, Storage Account and Load Balancer) and create a new AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address.

## Further information

For more information on Azure Virtual Machines and Virtual Machine Extensions:

- [Virtual Machine Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Virtual Machine REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/virtualmachines)
- [Virtual Machine Extension REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/extensions)

---

This is based on the [active-directory-new-domain-ha-2-dc](https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc) Azure Quick Start Template.
