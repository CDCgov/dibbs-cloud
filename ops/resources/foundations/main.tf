resource "azurerm_resource_group" "rg" {
  name     = "${var.team}-${var.project}-${var.env}"
  location = var.location
}

resource "azurerm_app_service" "webapp" {
  name                = "webapp-service-${terraform.workspace}-${var.team}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  client_cert_enabled = true

  site_config {
    always_on                = true
    dotnet_framework_version = "v4.0"
    http2_enabled            = true
  }

  auth_settings {
    enabled = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = "dibbs-webapp"
  }
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.team}-${var.env}-kv"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
  }
}

resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.team}${var.project}${var.env}acr"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "app" {
  account_replication_type         = "GRS" # Cross-regional redundancy
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  name                             = "${var.team}${var.project}${var.env}sa"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resource_group_location
  name                = "test-cluster"
  resource_group_name = var.resource_group_name
  dns_prefix          = "dns"

  addon_profile {
    oms_agent {
      enabled = true
    }
  }

  api_server_authorized_ip_ranges = [
    "10.30.0.0/16"
  ]

  # RBAC enabled (default is false when missing)
  azure_active_directory_role_based_access_control {
    managed = true
    #admin_group_object_ids =
    azure_rbac_enabled = true
  }

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
    network_policy    = "calico"
    network_plugin    = "azure"
    dns_service_ip    = var.aks_dns_service_ip
    load_balancer_sku = "standard"
    service_dir       = var.aks_service_cidr
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