locals {
  helm_values = [{
    kafka = {
      bootstrapServers = "PLAINTEXT://edh-ephemeral-kafka-bootstrap:9092"
    }
  }]
}
