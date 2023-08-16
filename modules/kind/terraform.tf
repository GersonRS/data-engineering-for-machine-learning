terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.1.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }
}
