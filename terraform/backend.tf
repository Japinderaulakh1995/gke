terraform {
    backend "gcs" { 
      bucket  = "ey-devops-terraform-state-backup"
    }
}
