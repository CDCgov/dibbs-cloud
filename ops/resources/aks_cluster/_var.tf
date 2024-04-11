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
  description = "The name of the resource group to deploy to"
  type        = string
}

variable "aks_subnet_id" {
  description = "The ID of the subnet to connect the AKS cluster to"
  type        = string
}

variable "agic_id" {
  description = "The ID of the Application Gateway Ingress Controller"
  type        = string
}

variable "aks_agent_os_disk_size" {
  type        = number
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 40
}

variable "aks_agent_count" {
  type        = number
  description = "The number of agent nodes for the cluster."
  default     = 1
}

variable "aks_agent_vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_D2_v2"
}

variable "aks_service_cidr" {
  type        = string
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  type        = string
  description = "DNS server IP address"
  default     = "10.0.0.10"
}