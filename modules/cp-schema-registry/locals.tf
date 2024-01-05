locals {
  helm_values = [{
    kafka = {
      bootstrapServers = "PLAINTEXT://${var.kafka_broker_name}-kafka-bootstrap:9092"
    }
  }]
}
