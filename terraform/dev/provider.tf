provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  # credentials not required since it's being passed through GITHUB secrets
}
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.dev_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.dev_cluster.master_auth[0].cluster_ca_certificate,
  )
}
/*
provider "kubernetes" {
  config_path = "~/.kube/config"
}
*/
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
