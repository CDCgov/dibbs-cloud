variable "project" {
  default = "#{vars.project}"
}

variable "app_name" {
  default = "#{vars.app_name}"
}

variable "env" {
  description = "values: [dev, prod]"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy to"
  type        = string
}

variable "network_address" {
  description = "The network address of the virtual network"
}
variable "management_tags" {
  description = "The tags to apply to the management resources"
  type        = map(string)
}

variable "location" {
  description = "The location of the resource group to deploy to"
  type        = string
}
