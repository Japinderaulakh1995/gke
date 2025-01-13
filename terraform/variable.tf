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
variable "gke_node_cidr" {
  description = "cidr range for nodes"
  default = "10.0.0.0/18"
}

variable "pods_cidr" {
  description = "cidr range for pod"
  default = "10.48.0.0/14"
}

variable "svc_cidr" {
  description = "cidr range for service"
  default = "10.52.0.0/20"
}

variable "master_ipv4_cidr_block" {
  description = "cidr range for service"
  default = "172.17.0.0/28"
}
