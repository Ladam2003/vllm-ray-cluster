terraform {
  required_version = ">= 1.4.0"

  required_providers {
    openstack = { source = "terraform-provider-openstack/openstack", version = "~> 1.53.0" }
    aws       = { source = "hashicorp/aws", version = "~> 5.0" }
    azurerm   = { source = "hashicorp/azurerm", version = "~> 3.0" }
    google    = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

# OpenStack
provider "openstack" {
  count = var.cloud_provider == "openstack" ? 1 : 0
  auth_url    = var.openstack_auth_url
  region      = var.openstack_region
  application_credential_id     = var.openstack_app_cred_id
  application_credential_secret = var.openstack_app_cred_secret
}

# AWS
provider "aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  region = var.aws_region
}

# Azure
provider "azurerm" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  features = {}
}

# GCP
provider "google" {
  count       = var.cloud_provider == "gcp" ? 1 : 0
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = var.gcp_credentials_json
}
