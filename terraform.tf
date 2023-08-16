terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "5.4.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.3.1"
    }
  }
}
