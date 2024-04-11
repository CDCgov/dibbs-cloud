# Contents

Containers are the bread and butter of functional application stacks. Depending on the complexity of your system, you may be well-suited to use a variety of container services. The following container paradigms are supported as part of this project:

| Component | Description | Template Link |
| --- | --- | --- |
| App Service | Azure App Service is a fully managed platform for building, deploying, and scaling web apps. This implementation focuses on monolithic container setups, which is perfect for a single application with no internal dependencies. | [App Service](./01-app_service.md) |
| Azure Kubernetes Service | Azure Kubernetes Service (AKS) is a managed Kubernetes service that allows you to deploy, manage, and scale containerized applications using Kubernetes. This implementation focuses on a single cluster setup, which is perfect for applications that require a high level of control over the underlying infrastructure, with multiple microservice workloads to manage. | [Azure Kubernetes Service](./02-aks_cluster.md) |
