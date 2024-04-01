resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resource_group_location
  name                = "test-cluster"
  resource_group_name = var.resource_group_name
  dns_prefix          = "dns"

  api_server_authorized_ip_ranges = [
    "10.30.0.0/16"
  ]

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# SSH Key
resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "phdi-playground-${terraform.workspace}-ssh-key"
  location  = var.location
  parent_id = data.azurerm_resource_group.rg.id
}

resource "azurerm_log_analytics_workspace" "az_logs" {
  name                = "az_logs-${var.env}-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}