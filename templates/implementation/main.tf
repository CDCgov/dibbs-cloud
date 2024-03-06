locals {
  team     = "#{vars.team}"
  project  = "#{vars.project}"
  env      = "#{vars.env}"
  location = "#{vars.location}"
}

module "foundations" {
  source   = "../resources/foundations"
  team     = local.team
  project  = local.project
  env      = local.env
  location = local.location
}