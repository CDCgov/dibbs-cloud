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

variable "tenant_id" {
  description = "The current Azure tenant ID"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the source Azure Key Vault"
  type        = string
}

variable "webapp_subnet_id" {
  description = "The ID of the subnet to connect the app service to"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy to"
  type        = string
}