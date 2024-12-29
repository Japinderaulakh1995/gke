resource "google_storage_bucket" "raw" {
  project = var.project
  name = "${var.project_name}-raw"
  force_destroy = false
  uniform_bucket_level_access = true
  location = var.region
  labels = local.labels
}