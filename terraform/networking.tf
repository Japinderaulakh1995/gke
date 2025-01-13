#resource "google_compute_network" "vpc_network" {
#  name                    = "${var.project_name}-vpc"
#  auto_create_subnetworks = false
# lifecycle {
#   prevent_destroy = true
# }
#}
data "google_compute_network" "vpc_network" {
  name    = "ey-devops-vpc"                
  project = "my-project-id"         
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.gke_node_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  secondary_ip_range {
    range_name    = "pods-subnet"
    ip_cidr_range = var.pods_cidr
  }
  secondary_ip_range {
    range_name    = "services-subnet"
    ip_cidr_range = var.svc_cidr
  }
}
#####################################################
resource "google_compute_router" "nat_router" {
  name    = "${var.project_name}-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_address" "global_ip" {
  name         = "${var.project_name}-global-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.global_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

##########################################################
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
