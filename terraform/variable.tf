locals {
    labels = {
        "project_name" = var.project_name
    }
}

variable "project" {
    type= string
    description = "ID Google project"
}

variable "region" {
    type= string
    description = "Region Google project"
}

variable  "project_name" {
    type = string
    description = "Name of data pipeline project to use as resource prefix"
}
