terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 5.4.0"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1"
    }
  }
}
