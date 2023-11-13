variable "project_id" {
  type        = string
  description = "The project ID to manage"
}

variable "cluster_name" {
  description = "GKE cluster name"
}

variable "master_location" {
  description = "Master Region or Zone"
}

variable "min_master_version" {
  type        = string
  description = "Master min version"
  default     = ""
}
variable "nodes_location" {
  description = "Nodes Zones list"
  type        = list(any)
}

variable "release_channel" {
  description = "Cluster upgrade channel"
  default     = "STABLE"
}

variable "master_cidr" {
  description = "Master cidr block. Must be /28"
}

variable "pods_cidr" {
  description = "Pods cidr block"
}

variable "master_authorized_networks_config" {
  description = "Master authorized networks config"
}

variable "services_cidr" {
  description = "Services cird block"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "subnet_id" {
  description = "Subnet id"
}


variable "labels" {
  description = "Resource labels"
  type        = map(string)
}
