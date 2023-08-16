terraform {
  required_providers {

    external = {
      source = "hashicorp/external"
      version = "2.3.1"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.3.1"
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
