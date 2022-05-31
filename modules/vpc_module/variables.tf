variable "base_cidr_block" {
  description = "A /16 CIDR range definition, such as 10.1.0.0/16, that the VPC will use"
  default = "172.44.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  description = "A list of availability zones in which to create subnets"
  default = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
}