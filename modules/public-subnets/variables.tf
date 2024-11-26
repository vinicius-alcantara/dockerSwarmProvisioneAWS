variable "vpc_id" {
  type = string
}

variable "prefix_subnet_name_public" {
  type = string
}

variable "subnet_cidrs_public" {
  type = list(string)
}

variable "subnet_count_public" {
  type = number
}

variable "internet_gw" {
  type = string
}

data "aws_availability_zones" "available" {}