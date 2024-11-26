variable "vpc_name" {
  type    = string
  default = "devops-lab"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "prefix_subnet_name_public" {
  type    = string
  default = "devops-lab-public"
}

variable "subnet_cidrs_public" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "subnet_count_public" {
  type    = number
  default = 3
}

variable "internet_gw" {
  type    = string
  default = "devops-lab-internet-gw"
}

variable "prefix_subnet_name_private" {
  type    = string
  default = "devops-lab-private"
}

variable "subnet_cidrs_private" {
  type = list(string)
  default = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}

variable "subnet_count_private" {
  type    = number
  default = 3
}

variable "nat_gw_name" {
  type    = string
  default = "devops-lab-nat-gw"
}


