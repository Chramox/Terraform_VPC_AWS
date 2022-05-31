terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

locals {
  DateTime = formatdate("DD MMM YYYY - HH:mm AA ZZZ", timestamp())
}

variable "aws_region" {
    default = "us-west-2"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      CreationDateTime = local.DateTime
      Owner       = "JuanIbarra"
    }
  }
   
}


module "autoscaling_group" {
  source = "./modules/autoscaling_module"
}
