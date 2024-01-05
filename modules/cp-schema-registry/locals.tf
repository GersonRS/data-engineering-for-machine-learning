locals {
  helm_values = [{
    cp-helm-charts = {
      kafka = {
        bootstrapServers = "PLAINTEXT://${var.kafka_broker_name}-kafka-bootstrap:9092"
      }
    }
  }]
}
