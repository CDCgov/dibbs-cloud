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

variable "database_server_id" {
  description = "Identifier corresponding to the intended destination database server"
  default     = null
}

variable "storage_account_name" {
  description = "Name of the storage account to which data will be stored."
  type        = string
}

variable "storage_account_key" {
  description = "Key for the destination storage account."
  type        = string
}

variable "octopus_image_version" {
  description = "The version of the custom Octopus image to deploy"
  type        = string
}

variable "acr_url" {
  description = "The URL of the Azure Container Registry"
  type        = string
}

variable "acr_username" {
  description = "The username for the Azure Container Registry"
  type        = string
}

variable "acr_password" {
  description = "The password for the Azure Container Registry"
  type        = string
}