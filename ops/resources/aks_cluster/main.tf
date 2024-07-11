locals {
  name = "${var.team}-${var.project}-${var.env}"
}

resource "azurerm_log_analytics_workspace" "analytics" {
  name                = "${local.name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  daily_quota_gb = 5
}

#tfsec:ignore:azure-container-configured-network-policy:exp:2024-07-01
#tfsec:ignore:azure-container-limit-authorized-ips:exp:2024-07-01
#tfsec:ignore:azure-container-use-rbac-permissions:exp:2024-07-01
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${local.name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.name

  azure_policy_enabled = true
#based ths ip off of the aks_service_cidr, this value should Limit the access to the API server to a limited IP range
  api_server_access_profile {
    authorized_ip_ranges = [
      "10.0.0.0/16"
    ]

  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.analytics.id
  }

  default_node_pool {
    name            = "agentpool"
    node_count      = var.aks_agent_count
    vm_size         = var.aks_agent_vm_size
    os_disk_size_gb = var.aks_agent_os_disk_size
    vnet_subnet_id  = var.aks_subnet_id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.service_principal_client_id.value
    client_secret = data.azurerm_key_vault_secret.service_principal_client_secret.value
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = var.aks_dns_service_ip
    service_cidr   = var.aks_service_cidr
  }

  ingress_application_gateway {
    gateway_id = var.agic_id
  }

  http_application_routing_enabled = false

  linux_profile {
    admin_username = var.vm_username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }

  lifecycle {
    ignore_changes = [key_vault_secrets_provider, web_app_routing]
  }
}

variable "vm_username" {
  type        = string
  description = "User name for the VM"
  default     = "aks_user"
}