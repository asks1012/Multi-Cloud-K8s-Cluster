terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.14.0"
    }
  }
}

provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["/home/sagar/.aws/credentials"]
  profile                  = "default"
}

provider "azurerm" {
  features {}
  subscription_id = "YOUR_SUBSCRIPTION_ID"
  tenant_id       = "YOUR_TENANT_ID"
  client_id       = "YOUR_CLIENT_ID"
  client_secret   = "YOUR_CLIENT_SECRET"
}
