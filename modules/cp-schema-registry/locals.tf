locals {
  helm_values = [{
    cp-helm-charts = {
      cp-kafka = {
        enabled = false
      }
      cp-zookeeper = {
        enabled = false
      }
      cp-schema-registry = {
        enabled = true
        kafka = {
          bootstrapServers = "PLAINTEXT://${var.kafka_broker_name}-kafka-bootstrap:9092"
        }
      }
      cp-kafka-rest = {
        enabled = false
      }
      cp-kafka-connect = {
        enabled = false
      }
      cp-ksql-server = {
        enabled = false
      }
      cp-control-center = {
        enabled = false
      }
    }
  }]
}
