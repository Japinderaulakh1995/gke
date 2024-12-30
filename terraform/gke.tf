resource "google_container_cluster" "primary" {
  name               =  "${var.project_name}-cluster"
  location           = var.region
  initial_node_count = 1
  deletion_protection = false
  network            = google_compute_network.vpc_network.name
  subnetwork         = google_compute_subnetwork.subnetwork.name
ip_allocation_policy {
    cluster_secondary_range_name  = "pods-subnet"
    services_secondary_range_name = "services-subnet"
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}
######################################################################
resource "google_container_node_pool" "general" {
  name       ="${var.project_name}-node-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
   autoscaling {
    min_node_count = 2
    max_node_count = 4
  }

  node_config {
    preemptible  = false
    machine_type = "ec2-small"

    service_account =  "gke-terrafrom@sacred-epigram-446218-g5.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
