terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 1.6"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 1"
    }
    jwt = {
      source  = "camptocamp/jwt"
      version = ">= 1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 6"
    }
  }
  required_version = ">= 1.2"
}
