variable "sg_count" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "prefix_sg_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    self             = bool
  }))
  default = []
}
