locals {
  /*backend_address_pool_name      = "${var.vnet_name}-beap"
  frontend_port_name             = "${var.vnet_name}-feport"
  frontend_ip_configuration_name = "${var.vnet_name}-feip"
  http_setting_name              = "${var.vnet_name}-be-htst"
  listener_name                  = "${var.vnet_name}-httplstn"
  request_routing_rule_name      = "${var.vnet_name}-rqrt"*/

  http_listener   = "${local.name}-http"
  https_listener  = "${local.name}-https"
  frontend_config = "${local.name}-config"
  redirect_rule   = "${local.name}-redirect"

  orchestration_backend_pool          = "${var.name}-${var.env}-be-api"
  orchestration_backend_http_setting  = "${var.name}-${var.env}-be-api-http"
  orchestration_backend_https_setting = "${var.name}-${var.env}-be-api-https"

  #networkContributorRole         = "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', '4d97b98b-1d4f-4787-a291-c67834d212e7')]"
}

resource "azurerm_private_dns_zone" "aca" {
  name                = "${local.name}.privatelink.azurecontainer.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "aca_ingress" {
  name                = "${local.name}-aca-gateway-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  domain_name_label = local.name
}

resource "azurerm_application_gateway" "load_balancer" {
  name                = "${local.name}-app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.autoscale_min
    max_capacity = var.autoscale_max
  }

  gateway_ip_configuration {
    name      = "${local.name}-gateway-ip-config"
    subnet_id = var.aca_subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.gateway.id]
  }

  # ------- Static -------------------------
  backend_address_pool {
    name  = local.static_backend_pool
    fqdns = [var.blob_endpoint]
  }

  backend_http_settings {
    name                                = local.static_backend_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "static-http"
  }

  backend_http_settings {
    name                                = local.static_backend_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "static-https"
  }

  # Need a custom health check for static sites as app gateway doesn't support it
  probe {
    name                                      = "static-http"
    interval                                  = 10
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Http"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                                      = "static-https"
    interval                                  = 10
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Https"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      status_code = ["200-399"]
    }
  }

  # ------- Backend Orchestration Endpoint -------------------------
  backend_address_pool {
    name         = local.orchestration_backend_pool
    fqdns        = var.fqdns //HAS to be FQDN of the orchestration container.
    ip_addresses = var.ip_addresses
  }

  backend_http_settings {
    name                                = local.orchestration_backend_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "be-http"
  }

  backend_http_settings {
    name                                = local.orchestration_backend_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = "be-https"
  }

  probe {
    name                                      = "be-http"
    interval                                  = 10
    path                                      = "/actuator/health" //TODO: Change to Orchestration endpoint
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Http"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      body        = "UP"
      status_code = [200]
    }
  }

  probe {
    name                                      = "be-https"
    interval                                  = 10
    path                                      = "/actuator/health"
    pick_host_name_from_backend_http_settings = true
    protocol                                  = "Https"
    timeout                                   = 10
    unhealthy_threshold                       = 3

    match {
      body        = "UP"
      status_code = [200]
    }
  }

  # ------- Backend Metabase App ------------------------- ECR VIEWER
  backend_address_pool {
    name         = local.metabase_pool
    fqdns        = var.metabase_fqdns //HAS to be the fqdn of the ecr viewer.
    ip_addresses = var.metabase_ip_addresses
  }

  backend_http_settings {
    name                                = local.metabase_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = local.metabase_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  # ------- Backend Staging Slot -------------------------
  backend_address_pool {
    name         = local.staging_pool
    fqdns        = var.staging_fqdns
    ip_addresses = var.staging_ip_addresses
  }

  backend_http_settings {
    name                                = local.staging_http_setting
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "be-http"
  }

  backend_http_settings {
    name                                = local.staging_https_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    probe_name                          = "be-https"
  }

  # ------- Listeners -------------------------

  frontend_ip_configuration {
    name                 = local.frontend_config
    public_ip_address_id = azurerm_public_ip.aca_ingress.id
  }

  # --- HTTP Listener
  frontend_port {
    name = local.http_listener
    port = 80
  }

  http_listener {
    name                           = local.http_listener
    frontend_ip_configuration_name = local.frontend_config
    frontend_port_name             = local.http_listener
    protocol                       = "Http"
  }

  # --- HTTPS Listener ---

  frontend_port {
    name = local.https_listener
    port = 443
  }

  http_listener {
    name                           = local.https_listener
    frontend_ip_configuration_name = local.frontend_config
    frontend_port_name             = local.https_listener
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.name
  }

  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.wildcard_simplereport_gov.secret_id
  }

  ssl_policy {
    policy_name = "AppGwSslPolicy20170401S"
    policy_type = "Predefined"
  }

  # ------- Routing -------------------------
  # HTTP -> HTTPS redirect
  request_routing_rule {
    name                        = local.redirect_rule
    priority                    = 100
    rule_type                   = "Basic"
    http_listener_name          = "${local.name}-http"
    redirect_configuration_name = local.redirect_rule
  }

  redirect_configuration {
    name = local.redirect_rule

    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
    target_listener_name = local.https_listener
  }

  # HTTPS path-based routing
  request_routing_rule {
    name                       = "${local.name}-routing-https"
    priority                   = 200
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.https_listener
    backend_address_pool_name  = local.static_backend_pool
    backend_http_settings_name = local.static_backend_https_setting
    url_path_map_name          = "${var.env}-urlmap"
  }

  //Should we default to orchestrator for the static pool?
  url_path_map {
    name                               = "${local.name}-urlmap"
    default_backend_address_pool_name  = local.static_backend_pool
    default_backend_http_settings_name = local.static_backend_https_setting
    default_rewrite_rule_set_name      = "simple-report-routing"

    dynamic "path_rule" {
      for_each = {
        for key, value in var.building_block_definitions : key => value if values.is_public
      }
      content {
        name = each.value.path_rule.name
        paths = each.value.path_rule.paths
        backend_address_pool_name = each.value.path_rule.backend_address_pool_name
        backend_http_settings_name = each.value.path_rule.backend_http_settings_name
        rewrite_rule_set_name = each.value.path_rule.rewrite_rule_set_name
      }
    }
  }

  redirect_configuration {
    name = local.redirect_self_registration_rule

    include_path         = true
    include_query_string = true
    redirect_type        = "Permanent"
    target_url           = local.app_url
  }

  rewrite_rule_set {
    name = "simple-report-metabase-routing"

    rewrite_rule {
      name          = "metabase-wildcard"
      rule_sequence = 100
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*/metabase(.*)"
        variable    = "var_uri_path"
      }

      url {
        path    = "/{var_uri_path_1}"
        reroute = false
        # Per documentation, we should be able to leave this pass-through out. See however
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = "{var_query_string}"
      }
    }
  }

  rewrite_rule_set {
    name = "simple-report-staging-routing"

    rewrite_rule {
      name          = "staging-wildcard"
      rule_sequence = 100
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*api/(.*)"
        variable    = "var_uri_path"
      }

      url {
        path    = "/{var_uri_path_1}"
        reroute = false
        # Per documentation, we should be able to leave this pass-through out. See however
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = "{var_query_string}"
      }
    }
  }

  rewrite_rule_set {
    name = "simple-report-routing"

    rewrite_rule {
      name          = "api-wildcard"
      rule_sequence = 101
      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*api/(.*)"
        variable    = "var_uri_path"
      }

      url {
        path    = "/{var_uri_path_1}"
        reroute = false
        # Per documentation, we should be able to leave this pass-through out. See however
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = "{var_query_string}"
      }
    }

    rewrite_rule {
      name          = "react-app"
      rule_sequence = 105

      condition {
        ignore_case = true
        negate      = false
        pattern     = ".*app/(.*)"
        variable    = "var_uri_path"
      }

      url {
        path = "/app"
        # This is probably excessive, but it was happening anyway: see
        # https://github.com/terraform-providers/terraform-provider-azurerm/issues/11563
        query_string = ""
        reroute      = true
      }
    }

    rewrite_rule {
      name          = "HSTS"
      rule_sequence = 101

      response_header_configuration {
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000"
      }
    }

  }

  depends_on = [
    azurerm_public_ip.static_gateway,
    azurerm_key_vault_access_policy.gateway
  ]

  firewall_policy_id = var.firewall_policy_id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


// Gateway analytics
resource "azurerm_monitor_diagnostic_setting" "logs_metrics" {
  name                       = "${var.name}-${var.env}-gateway-logs-metrics"
  target_resource_id         = azurerm_application_gateway.load_balancer.id
  log_analytics_workspace_id = var.log_workspace_uri

  dynamic "enabled_log" {
    for_each = [
      "ApplicationGatewayAccessLog",
      "ApplicationGatewayPerformanceLog",
      "ApplicationGatewayFirewallLog",
    ]
    content {
      category = enabled_log.value

      retention_policy {
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = [
      "AllMetrics",
    ]
    content {
      category = metric.value

      retention_policy {
        enabled = false
      }
    }
  }
}

/*
resource "azurerm_application_gateway" "aca" {
  name                = "${local.name}-aca-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "acaIpConfig"
    subnet_id = var.aca_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.aca_ingress.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 10
  }

  private_link_configuration {
    name = "${local.name}-aca-private-link"
    ip_configuration {
      name = "acaPrivateLinkIpConfig"
      subnet_id = var.aca_subnet_id
      primary = true
      private_ip_address_allocation = "Dynamic"
    }
  }

  depends_on = [
    azurerm_public_ip.aca_ingress
  ]
} */

