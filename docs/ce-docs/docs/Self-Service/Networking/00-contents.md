# Contents

Several networking components within Azure are used to generate a secure and resilient environment. The components we support are listed in the table below.

| Component | Description | Template Link |
| --- | --- | --- |
| Virtual Network | A virtual network (VNet) is a representation of your own network in the cloud. It is a logical isolation of the Azure cloud dedicated to your subscription. | [VNet](./01-vnet.md) |
| Application Gateway | Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications. At least one App Gateway is required to facilitate ingress traffic to the Azure Kubernetes Cluster, Container Instance, or App Service, if configured in your system. | [Application Gateway](./02-app_gateway.md) |