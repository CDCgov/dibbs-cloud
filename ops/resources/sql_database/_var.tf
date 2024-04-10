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

variable "global_vault_id" {
  description = "The ID of the global key vault"
  type        = string
}


variable "administrator_login" {
  type        = string
  description = "The administrator login for the SQL Server."
}

variable "webapp_subnet_id" {
  type        = string
  description = "The ID of the subnet where the client webapp is deployed."
}

variable "primary_access_key" {
  type = string
  description = "value of the primary access key for the storage account"
}

variable "primary_blob_endpoint" {
  type = string
  description = "Destination blob endpoint for the storage account"
}