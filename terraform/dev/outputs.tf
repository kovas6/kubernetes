output "kube_host" {
  value = data.google_container_cluster.primary.endpoint
}

output "client_token" {
  value     = data.google_client_config.default.access_token
  sensitive = true
}
