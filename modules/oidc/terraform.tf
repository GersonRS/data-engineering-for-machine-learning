terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4"
    }
    random = {
      source  = "random"
      version = ">= 3"
    }
    null = {
      source  = "null"
      version = ">= 3"
    }
  }
}
