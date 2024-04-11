locals {
  name = "${var.team}-${var.project}-${var.env}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${local.name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.name

  default_node_pool {
    name            = "agentpool"
    node_count      = var.aks_agent_count
    vm_size         = var.aks_agent_vm_size
    os_disk_size_gb = var.aks_agent_os_disk_size
    vnet_subnet_id  = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
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
}

variable "vm_username" {
  type        = string
  description = "User name for the VM"
  default     = "aks_user"
}