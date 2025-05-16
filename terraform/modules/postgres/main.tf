# Variables
variable "postgres_username" {
  description = "Username for PostgreSQL"
  type        = string
}

variable "postgres_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

# Namespace
resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "terraform_data" "postgres_credentials_hash" {
  input = sha256("${var.postgres_username}:${var.postgres_password}")
}

# Secret
resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.postgres.metadata[0].name

    # HIGHLIGHTED: Add annotation to force update on change
    annotations = {
      creds-hash = terraform_data.postgres_credentials_hash.output
    }
  }

  # HIGHLIGHTED: Let provider handle base64 encoding — cleaner diffs
  data = {
    username = var.postgres_username
    password = var.postgres_password
  }

  type = "Opaque"
}

# Storage Class
resource "kubernetes_storage_class" "premium_rwo_immediate" {
  metadata {
    name = "premium-rwo-immediate"
  }

  storage_provisioner = "pd.csi.storage.gke.io"
  reclaim_policy        = "Delete"
  volume_binding_mode   = "Immediate"
  allow_volume_expansion = true
}

# StatefulSet
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    service_name = kubernetes_service.postgres.metadata[0].name
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
      }
    }

    volume_claim_template {
      metadata {
        name      = "postgres-storage"
        namespace = kubernetes_namespace.postgres.metadata[0].name
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "1Gi" # HIGHLIGHTED: Set initial disk size manually
          }
        }

        storage_class_name = kubernetes_storage_class.premium_rwo_immediate.metadata[0].name
      }
    }
  }
}

# Service
resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    namespace = kubernetes_namespace.postgres.metadata[0].name
  }

  spec {
    cluster_ip = "None"  # HIGHLIGHTED: Headless service for StatefulSet 
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
