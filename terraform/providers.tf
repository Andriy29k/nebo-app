terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "state-file-rg"
    storage_account_name = "neboappsa"
    container_name       = "state-file"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
    subscription_id   = var.subscription
    features {}
}