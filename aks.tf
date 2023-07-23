# Copyright (c) HashiCorp, Inc.

# SPDX-License-Identifier: MPL-2.0
resource "random_pet" "prefix" {}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "eastus"
  tags = {
    environment = "prod"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  service_principal {

    client_id     = "47d1c5c6-634e-4cbb-bacc-f52c43062b60"

    client_secret = "mfw8Q~O7~gPdvEdZpAzTCHYRckLQ8zUFnENZRbdK"

  }

# role_based_access_control {

  #  enabled = true

  #}
  tags = {
    environment = "prod"
  }
}