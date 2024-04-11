variable "acr_image_tag" {
  description = "Octopus ACR tag to deploy"
  type        = string
}

variable "deploy_timestamp" {
  description = "The current date and time"
  type        = string
  default     = ""
}

variable "deploy_tag" {
  description = "The branch or tag that we are deploying"
  type        = string
  default     = ""
}

variable "deploy_workflow" {
  description = "The name of the workflow performing the deploy"
  type        = string
  default     = "N/A"
}

variable "deploy_runnumber" {
  description = "The run number of the deploy workflow"
  type        = number
  default     = -1
}

variable "deploy_actor" {
  description = "The ID of the person performing the release"
  type        = string
  default     = ""
}