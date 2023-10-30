locals {
  helm_values = [{
    controller = {
      ingress = {
        v1 = {
          # -- Specifies if you want to create an ingress access
          enabled : true
          # -- New style ingress class name. Only possible if you use K8s 1.18.0 or later version
          ingressClassName : "traefik"
          # -- Additional ingress annotations
          annotations = {
            "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
            "ingress.kubernetes.io/ssl-redirect"               = "true"
            "kubernetes.io/ingress.allow-http"                 = "false"
          }
          hosts = [
            "pinot.apps.${var.base_domain}",
            "pinot.apps.${var.cluster_name}.${var.base_domain}"
          ]
          # -- Ingress tls configuration for https access
          tls = [{
            secretName = "pinot-ingres-tls"
            hosts = [
              "pinot.apps.${var.cluster_name}.${var.base_domain}"
            ]
          }]
        }
      }
      # extra = {
      #   configs = <<-EOT
      #     pinot.set.instance.id.to.hostname=true
      #     controller.task.scheduler.enabled=true
      #     pinot.set.instance.id.to.hostname=true
      #     pinot.controller.storage.factory.class.s3=org.apache.pinot.plugin.filesystem.S3PinotFS
      #     pinot.controller.storage.factory.s3.endpoint=http://${var.storage.endpoint}/${var.storage.bucket_name}/segment-store/
      #     pinot.controller.storage.factory.s3.region=eu-west-1
      #     pinot.controller.storage.factory.s3.accessKey=${var.storage.access_key}
      #     pinot.controller.storage.factory.s3.secretKey=${var.storage.secret_access_key}
      #     pinot.controller.segment.fetcher.protocols=file,http,s3
      #     pinot.controller.segment.fetcher.s3.class=org.apache.pinot.common.utils.fetcher.PinotFSSegmentFetcher
      #     controller.local.temp.dir=/tmp/pinot-tmp-data/
      #   EOT
      # }
    }
    # server = {
    #   extra = {
    #     configs = <<-EOT
    #       pinot.set.instance.id.to.hostname=true
    #       pinot.server.instance.realtime.alloc.offheap=true
    #       pinot.query.server.port=7321
    #       pinot.query.runner.port=7732
    #       pinot.server.instance.realtime.alloc.offheap=true
    #       pinot.server.instance.currentDataTableVersion=2
    #       pinot.server.storage.factory.class.s3=org.apache.pinot.plugin.filesystem.S3PinotFS
    #       pinot.server.storage.factory.s3.endpoint=http://${var.storage.endpoint}/${var.storage.bucket_name}/segment-store/
    #       pinot.server.storage.factory.s3.region=eu-west-1
    #       pinot.server.storage.factory.s3.accessKey=${var.storage.access_key}
    #       pinot.server.storage.factory.s3.secretKey=${var.storage.secret_access_key}
    #       pinot.server.segment.fetcher.protocols=file,http,s3
    #       pinot.server.segment.fetcher.s3.class=org.apache.pinot.common.utils.fetcher.PinotFSSegmentFetcher
    #     EOT
    #   }
    # }
  }]
}
