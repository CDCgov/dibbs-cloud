# Application Gateway

An Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. At least one App Gateway is required to facilitate ingress traffic to the Azure Kubernetes Cluster, Container Instance, or App Service, if configured in your system.

For systems that utilize an Azure Kubernetes Cluster, an App Gateway can be configured as an AGIC: App Gateway Ingress Controller. This special binding grants seamless control over the traffic that enters the cluster, without the extra overhead of needing to deploy, configure, and manage a separate Ingress Controller (like NGINX).


## File Structure
App Gateway templates are located in the `templates/virtual_network` directory. The `main.tf` file contains the VNet and subnet resource definitions on which the App Gateway depends; the gateway object itself is contained within the `gateway.tf` file. The `_var.tf` file contains the input variables for the resource. The `_output.tf` file contains the output variables for the resource. Note that the variable and output files are shared with the virtual network resources, since there is a direct dependency (no VNet, no App Gateway).

```
- templates
  - virtual_network
    - main.tf
    - _var.tf
    - _output.tf
    - gateway.tf
```

## Usage
Example usage of this module, as configured for AGIC, can be found in the `templates/implementation` directory.