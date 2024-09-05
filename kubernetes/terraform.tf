terraform {
  backend "local" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.115.0"

    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.14.1"
    }
  }
}
