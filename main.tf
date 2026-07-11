terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.cluster_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.cluster_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_in_days
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.cluster_name
  location                          = azurerm_resource_group.this.location
  resource_group_name               = azurerm_resource_group.this.name
  dns_prefix                        = var.cluster_name
  sku_tier                          = "Standard"
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = var.private_cluster_enabled ? "System" : null
  role_based_access_control_enabled = true
  azure_policy_enabled              = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  tags                              = var.tags

  default_node_pool {
    name                 = "system"
    node_count           = var.node_count
    vm_size              = var.node_vm_size
    os_sku               = var.node_os_sku
    os_disk_type         = "Managed"
    vnet_subnet_id       = azurerm_subnet.aks.id
    type                 = "VirtualMachineScaleSets"
    auto_scaling_enabled = false
    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  depends_on = [azurerm_subnet.aks]
}

resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_container_registry" "this" {
  name = var.acr_name != "" ? var.acr_name : substr(lower("${var.cluster_name}acr${random_string.acr_suffix.result}"), 0, 50)
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.app_gateway_subnet_prefix]
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-${var.cluster_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = "appgw-${var.cluster_name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name        = "app-backend-pool"
    ip_addresses = [var.app_internal_lb_ip]
  }

  backend_http_settings {
    name                             = "app-http-settings"
    cookie_based_affinity            = "Disabled"
    port                             = 80
    protocol                         = "Http"
    request_timeout                  = 30
    pick_host_name_from_backend_address = false
    probe_name                       = "app-health-probe"
    host_name                        = var.app_internal_lb_ip
  }

  probe {
    name                               = "app-health-probe"
    protocol                           = "Http"
    host                               = var.app_internal_lb_ip
    path                               = "/api/health"
    interval                           = 30
    timeout                            = 30
    unhealthy_threshold                = 3
    pick_host_name_from_backend_http_settings = false
  }

  http_listener {
    name                           = "app-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "app-http-listener"
    backend_address_pool_name  = "app-backend-pool"
    backend_http_settings_name = "app-http-settings"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.this]
}

resource "azurerm_role_assignment" "kubelet_network_contributor" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  depends_on           = [azurerm_kubernetes_cluster.this]
}
