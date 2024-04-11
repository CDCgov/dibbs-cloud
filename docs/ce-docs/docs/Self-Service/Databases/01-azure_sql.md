# Azure SQL

Azure SQL is a relational database service that provides a variety of options for storing and querying data, leveraging the power of Microsoft SQL Server. This implementation focuses on a single database instance, which is perfect for applications that require a relational database with no additional frills. This template centers on the semi-managed instance, which gives you more control at a reduced cost, but with greater maintenance obligations.

## File Structure
Azure SQL templates are located in the `templates/sql_database` directory. The `main.tf` file contains the Azure SQL Server and Database resource definitions. The `_var.tf` file contains the input variables for the resources. The `_output.tf` file contains the output variables for the resources. The `vault.tf` file contains resources and data objects that tie into your Key Vault implementation for secure storage and retrieval of database administrator credentials.

```
- templates
  - sql_database
    - main.tf
    - _var.tf
    - _output.tf
    - vault.tf
```

## Usage
Example usage of this module can be found in the `templates/implementation` directory. At a minimum, you will need to implement the following local and module declarations in your environment definition file:

![SQL Server Usage](../../assets/sql_server.png)