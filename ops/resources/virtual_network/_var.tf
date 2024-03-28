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

variable "network_address_space" {
  description = "The desired address space for the full virtual network"
  type        = string
  default     = "10.30.0.0/16"
}

variable "k8s_subnet_address_prefix" {
  type        = string
  description = "IP address space for kubernetes subnet vnet"
  default     = "10.30.1.0/24"
}

variable "app_gateway_subnet_address_prefix" {
  type        = string
  description = "App gateway subnet server IP address space."
  default     = "10.30.5.0/24"
}

variable "lb_subnet_address_prefix" {
  type        = string
  description = "Load balancer subnet IP address space."
  default     = "10.30.7.0/24"
}

variable "app_gateway_sku" {
  type        = string
  description = "Name of the Application Gateway SKU"
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  type        = string
  description = "Tier of the Application Gateway tier"
  default     = "Standard_v2"
}
