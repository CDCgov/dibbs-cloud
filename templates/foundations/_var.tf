variable "team" {
  description = "One-word identifier for this project's custodial team."
  type        = string
}

variable "project" {
  description = "One-word identifier or code name for this project."
  type        = string
}

variable "env" {
  description = "One-word identifier for the target environment (e.g. dev, test, prod)."
  type        = string
}

variable "location" {
  description = "The Azure region in which the associated resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "value of the Azure resource group to deploy to"
}

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "node_count" {
  type        = number
  description = "The number of agent nodes for the cluster."
  default     = 1
}

variable "username" {
  type        = string
  description = "User name for the VM"
  default     = "aks_user"
}

variable "aks_dns_service_ip" {
  type        = string
  description = "DNS server IP address"
  default     = "10.0.0.10"
}