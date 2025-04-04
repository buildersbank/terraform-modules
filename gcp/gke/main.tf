resource "google_container_cluster" "_" {
  name     = var.cluster_name
  location = var.master_location
  project  = var.project_id

  min_master_version  = var.min_master_version
  node_locations      = var.nodes_location
  deletion_protection = var.deletion_protection

  release_channel {
    channel = var.release_channel
  }

  logging_config {
    enable_components = []
  }
  monitoring_config {
    enable_components = []
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = !var.is_public
    master_ipv4_cidr_block  = var.master_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks_config

      content {
        cidr_block = each.value
      }
    }
  }


  ## Pods and services ip blocks
  ## Recommend /14 for Pods and /20 for services
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.services_cidr
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  resource_labels = var.labels

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  network    = var.vpc_id
  subnetwork = var.subnet_id

  timeouts {
    create = "30m"
    update = "40m"
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      resource_labels,
    ]
  }
}
