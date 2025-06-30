terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "shengchang-test"
    storage_account_name = "shengchangpoctest"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = false
  }
}

provider "azurerm" {
  features {}
  use_oidc = false
}

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "rg-aks" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    dd_monitor  = "false"
    environment = "sb"
  }
}

# Add this to your main.tf if you want Terraform to manage the WAF policy
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "wafpocrule1"
  resource_group_name = azurerm_resource_group.rg-aks.name
  location            = azurerm_resource_group.rg-aks.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = {
    dd_monitor  = "false"
    environment = "sb"
  }
}
