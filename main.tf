terraform {
  required_version = "= 0.12.20"
}

provider "azurerm" {
  features {}
}

data "null_data_source" "common_tags" {
  inputs = {
    infrastructure = var.resource_group_name
  }
}

module "backend-1-0-0" {
  source = "github.com/bryan-nice/terraform-azure-modules?ref=1.1.0"
}

module "backend_resource_group" {
  source   = "./.terraform/modules/backend-1-0-0/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "resource group"
    )
  )
}

module "backend_storage_account" {
  source              = "./.terraform/modules/backend-1-0-0/storage/account"
  name                = var.storage_account_name
  resource_group_name = module.backend_resource_group.name
  location            = module.backend_resource_group.location
  account_tier        = "Standard"
  account_kind        = "BlobStorage"

  tags = merge(
    data.null_data_source.common_tags.outputs,
    map(
      "resource_type", "storage account"
    )
  )
}

module "backend_storage_container" {
  source               = "./.terraform/modules/backend-1-0-0/storage/container"
  names                = split(",", var.storage_container_names)
  storage_account_name = module.backend_storage_account.name
}