# Deployment of Kubernetes cluster in the Azure Container Service

Create a Kubernetes cluster in Azure using the Azure Container Service.

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

### Create a service principal

You will need a service principal credential that will be used by Kubernetes to interact with Azure APIs. To create a service principal in your tenant, use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) as follows:

```
# Ensure you use a long complex password
> az ad sp create-for-rbac --name "terraform-k8s-credentials" --role "Contributor" --password "${PASSWORD}"
```

Use the returned `appId` value for the `service_principal_client_id` variable in `terraform.tfvars`. Use the ${PASSWORD} value for the `service_principal_client_secret` variable in `terraform.tfvars`.

### Generate an ssh key

Generate an ssh key as follows:

```
> ssh-keygen -t rsa -b 2048 
```

Copy the contents of the following and place into the `admin_ssh_publickey` variable in `terraform.tfvars`:

```
> cat ~/.ssh/id_rsa.pub
```

There are instructions for using PuTTY on Windows to generate your ssh keys [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows).

More information on using ssh with VMs in Azure:

- [How to create and use an SSH public and private key pair for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
- [How to Use SSH keys with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)

## Further information

For more information on Azure Container Service:

- [Container Service Documentation](https://docs.microsoft.com/en-us/azure/container-service/)
- [Container Service REST API Reference](https://docs.microsoft.com/en-us/rest/api/compute/containerservices)
- [Get started with a Kubernetes cluster in Azure Container Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-walkthrough)
- [About the Azure Active Directory service principal for a Kubernetes cluster in Azure Container Service](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-service-principal)

---

This is based on the [101-acs-kubernetes](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-kubernetes) Azure Quick Start Template.
