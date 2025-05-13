provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # credentials not required since it's being passed through GITHUB secrets
}

provider "kubernetes" {
  host  = "https://${google_container_cluster.main.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.main.master_auth[0].cluster_ca_certificate)
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone
}

provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}
