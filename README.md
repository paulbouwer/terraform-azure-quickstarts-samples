# Terraform - Azure Quickstarts

## Overview

Reference Azure Terraform templates for the most common Azure deployment patterns.

## Azure Authentication

The following arguments are required to authenticate against the AzureRM Provider:

- **subscription_id** - The subscription ID to use. It can also be sourced from the *ARM_SUBSCRIPTION_ID* environment variable.
- **client_id** - The client ID to use. It can also be sourced from the *ARM_CLIENT_ID* environment variable.
- **client_secret** - The client secret to use. It can also be sourced from the *ARM_CLIENT_SECRET* environment variable.
- **tenant_id** - The tenant ID to use. It can also be sourced from the *ARM_TENANT_ID* environment variable.
- **environment** - (Optional) The cloud environment to use. It can also be sourced from the *ARM_ENVIRONMENT* environment variable. Supported values are:
   - public (default) 
   - usgovernment 
   - german 
   - china 


## Obtaining the Azure Authentication details

Authenticate using the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). 

```
> az login
```

If you have multiple Azure Subscriptions, their details will be returned by the `az login` command. Set the `SUBSCRIPTION_ID` environment variable to hold the value of the returned `id` field from the Subscription you want to use. 

Set the Subscription that you want to use for this session.

```
> az account set --subscription="${SUBSCRIPTION_ID}"
```


## Subscription and Tenant Details

Query the account to get the Subscription Id and Tenant Id values.

```
> az account show --query "{subscriptionId:id, tenantId:tenantId}"
```

## Create Azure Credentials

It is advisable to create separate credentials for Terraform. These can be created as follows:

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```

This will output your client_id, client_secret (password), sp_name, and tenant. Take note of the **client_id** and **client_secret**.

You can confirm your credentials (service principal) by opening a new shell and run the following commands substituting in the returned values for **sp_name**, **client_secret**, and **tenant**:

```
> az login --service-principal -u SP_NAME -p CLIENT_SECRET --tenant TENANT
> az vm list-sizes --location westus
```

### Environment Variables

Set the following environment variables from the values you have obtained:

- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
