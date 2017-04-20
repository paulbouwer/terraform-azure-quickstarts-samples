# Create Key Vault

This template creates an Azure Key Vault. 

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

You will need a service principal credential that has rights to the Azure Key Vault. To create a service principal in your tenant, use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) as follows:

```
# Ensure you use a long complex password
> az ad sp create-for-rbac --name "terraform-keyvault-credentials" --password "${PASSWORD}"

# Keep objectId and applicationId from the following command
> az ad sp list --display-name "terraform-keyvault-credentials"
```

Use the `objectId` value for the `keyvault_object_id` variable in `terraform.tfvars`.

Use the `ARM_TENANT_ID` environment variable value for the `keyvault_tenant_id` variable in in `terraform.tfvars`.

Save the `applicationId` value to use as the Service Principal Username in the validation steps later.

## Post validation

### Verify Key Vault credentials and access

You can verify that the credentials you created earlier have been granted the correct access to the Azure Key Vault as follows:

```
# Use the applicationId value you saved from earlier as the service principal username
> az login --service-principal -u "${APPLICATION_ID}" -p "${PASSWORD}" -t "${TENANT_ID}"

# If you do not get an "access denied", then everything is correctly configured
# Ensure that the action here matches how you configured "secrets_permissions" in "terraform.tfvars"
> az keyvault secret list --vault-name "terraformvault"
```

## Further information

For more information on Azure Key Vault:

- [Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Key Vault REST API Reference](https://docs.microsoft.com/en-us/rest/api/keyvault/)

---

This is based on the [101-key-vault-create](https://github.com/Azure/azure-quickstart-templates/tree/master/101-key-vault-create) Azure Quick Start Template.