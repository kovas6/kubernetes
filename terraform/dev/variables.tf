variable "project_id" {
  type        = string
  description = "The ID of the GCP project"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The GCP region"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "The GCP zone"
}

variable "cluster_name" {
  type        = string
  default     = "my-cluster"
  description = "The name of the GKE cluster"
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Number of nodes in the node pool"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "GCP machine type for the cluster nodes"
}

variable "preemptible" {
  type        = bool
  default     = false
  description = "Whether nodes should be preemptible"
}
