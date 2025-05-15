# File: modules/postgres/main.tf

variable "postgres_username" {
  description = "Username for PostgreSQL"
  type        = string
}

variable "postgres_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name = "postgres-secret"
  }

  data = {
    username = base64encode(var.postgres_username)
    password = base64encode(var.postgres_password)
  }

  type = "Opaque"
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    service_name = "postgres"      
    replicas     = 1             

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15"

          env {
            name  = "POSTGRES_DB"
            value = "appdb"
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "postgres"
          }

          port {
            container_port = 5432
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }

    # volume_claim_template is preferred for StatefulSet dynamic PVCs, but keeping PVC as is
    # volume_claim_template {
    #   metadata {
    #     name = "postgres-storage"
    #   }
    #
    #   spec {
    #     access_modes = ["ReadWriteOnce"]
    #
    #     resources {
    #       requests = {
    #         storage = "2Gi"
    #       }
    #     }
    #
    #     storage_class_name = "premium-rwo-immediate"
    #   }
    # }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    cluster_ip = "None"    # CHANGED: make it a headless service for StatefulSet
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
