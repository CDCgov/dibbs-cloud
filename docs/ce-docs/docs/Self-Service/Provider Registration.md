# Resource Provider Registration
For new subscriptions, several features may potentially be disabled. This is a default security measure Azure puts in place to ensure that costly features are not activated without explicit consent by an administrator. In order to use these features and services, you will need to manually register them with your subscription. This can be done through the Azure portal or via the Azure CLI.

For further information about registering via the portal, please consult the [Azure documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider).

To register via the Azure CLI, please refer to [the API documentation](https://learn.microsoft.com/en-us/powershell/module/az.resources/register-azresourceprovider?view=azps-11.3.0)

## Known Components
The following components will need registration on first use:

- Azure Container Registry
- Key Vault