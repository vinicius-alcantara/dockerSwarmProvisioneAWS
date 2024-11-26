variable "vpc_id" {
  type = string
}

variable "prefix_subnet_name_private" {
  type = string
}

variable "subnet_cidrs_private" {
  type = list(string)
}

variable "subnet_count_private" {
  type = number
}

variable "nat_gw_name" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

data "aws_availability_zones" "available" {}
