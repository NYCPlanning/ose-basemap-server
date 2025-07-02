terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cartography" {
  name     = "cartography-resources"
  location = "eastus2"
}

resource "azurerm_log_analytics_workspace" "basemap" {
  name                = "basemap-analytics"
  location            = azurerm_resource_group.cartography.location
  resource_group_name = azurerm_resource_group.cartography.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "basemap" {
  name                       = "basemap-environment"
  location                   = azurerm_resource_group.cartography.location
  resource_group_name        = azurerm_resource_group.cartography.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.basemap.id
}

resource "azurerm_container_app" "basemap" {
  name                         = "basemap-server"
  container_app_environment_id = azurerm_container_app_environment.basemap.id
  resource_group_name          = azurerm_resource_group.cartography.name
  revision_mode                = "Single"

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }

  }

  template {
    min_replicas = 1
    max_replicas = 10

    container {
      name   = "basemaptileserver"
      image  = "docker.io/maptiler/tileserver-gl-light:v5.3.1"
      cpu    = 0.25
      memory = "0.5Gi"

      volume_mounts {
        name = "data"
        path = "/data"
      }
    }

    volume {
      name         = "data"
      storage_name = azurerm_container_app_environment_storage.basemap.name
      storage_type = "AzureFile"
    }

  }
}

resource "azurerm_storage_account" "content" {
  name                     = "cartographycontent"
  resource_group_name      = azurerm_resource_group.cartography.name
  location                 = azurerm_resource_group.cartography.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "basemapcontent" {
  name               = "basemapcontent"
  storage_account_id = azurerm_storage_account.content.id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "basemap" {
  name                         = "basemapstorage"
  container_app_environment_id = azurerm_container_app_environment.basemap.id
  account_name                 = azurerm_storage_account.content.name
  share_name                   = azurerm_storage_share.basemapcontent.name
  access_key                   = azurerm_storage_account.content.primary_access_key
  access_mode                  = "ReadOnly"
}
