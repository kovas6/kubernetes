terraform {
  backend "gcs" {
    bucket = "kovas6-bucket-1"  
    prefix = "terraform/state"
  }
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    machine_type = var.machine_type
    preemptible  = var.preemptible
  }
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = var.zone
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    preemptible  = var.preemptible
  }
}

#module "postgres" {
#  source = "../modules/postgres"
# 
#  postgres_username = var.postgres_username
#  postgres_password = var.postgres_password
#}

