locals {
  helm_values = [{
    kafka = {
      bootstrapServers = "PLAINTEXT://edh-kafka-bootstrap:9092"
    }
  }]
}
