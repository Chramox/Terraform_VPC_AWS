terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

variable "aws_region" {
    default = "us-west-2"
}

provider "aws" {
  region = var.aws_region
}


module "autoscaling_group" {
  source = "./modules/autoscaling_module"
}
