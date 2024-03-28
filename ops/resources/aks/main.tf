resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resource_group_location
  name                = "test-cluster"
  resource_group_name = var.resource_group_name
  dns_prefix          = "dns"

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
      # key_data = jsondecode(azurerm_ssh_public_key.ssh_public_key_gen.output).publicKey
      key_data = var.public_key
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}