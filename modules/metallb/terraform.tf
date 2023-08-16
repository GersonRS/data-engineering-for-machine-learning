terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2"
    }
  }
}
