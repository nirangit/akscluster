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

    client_id     = "fef95b80-356f-4e8f-ab56-2b325572b589"

    client_secret = "D1v8Q~ITVAou~8f9wBKNo~X01IBggzil2SGsEcSF"

  }

# role_based_access_control {

  #  enabled = true

  #}
  tags = {
    environment = "prod"
  }
}