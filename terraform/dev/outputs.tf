output "kube_host" {
  value = data.google_container_cluster.primary.endpoint
}

output "client_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "cluster_name" {
  value = var.cluster_name
}
