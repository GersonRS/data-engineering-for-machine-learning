terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 5"
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
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
  }
  required_version = ">= 1.2"
}
