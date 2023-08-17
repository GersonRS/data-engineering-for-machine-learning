locals {
  helm_values = [{
    image = {
      repository = "rayproject/ray-ml"
      tag = "2.6.3-py38-cpu"
    }
  }]
}
