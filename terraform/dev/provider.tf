provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # credentials is not needed as GCP credentials are provided via environment variable
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.cluster.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}
