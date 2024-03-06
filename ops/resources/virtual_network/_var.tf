variable "team" {
  description = "One-word identifier for this project's custodial team."
  type = string
}

variable "project" {
  description = "One-word identifier or code name for this project."
  type = string
}

variable "env" {
  description = "One-word identifier for the target environment (e.g. dev, test, prod)."
  type = string
}

variable "location" {
  description = "The Azure region in which the associated resources will be created."
  type = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy to"
  type        = string
}

variable "network_address" {
  description = "The network address of the virtual network"
}
