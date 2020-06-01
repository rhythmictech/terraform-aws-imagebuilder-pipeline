##################################################
# Provider/Backend/Workspace Check
##################################################
provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 0.12.25"
  required_providers {
    aws = "~> 2.61.0"
  }
}

variable "owner" {
  description = "Team/person responsible for resources defined within this project"
  type        = string
}

variable "region" {
  description = "Region resources are being deployed to"
  type        = string
}
