variable "bastion_ami_id" {
  type    = string
  default = "ami-0c0b74d29acd0cd97"
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bastion_instance_count" {
  type    = number
  default = 1
}

variable "key_name_bastion" {
  type    = string
  default = "devops-lab-bastion-host"
}

# variable "username_bastion" {
#   type    = string
#   default = "myuser"
# }

# variable "password_bastion" {
#   type      = string
#   sensitive = true
#   default   = "xxxyyyzzzkkk"
# }

variable "bastion_prefix_instance_name" {
  type    = string
  default = "bastion"
}

variable "eip_bastion_count" {
  type    = number
  default = 1
}

variable "sg_count_bastion" {
  type    = number
  default = 1
}

variable "prefix_sg_bastion" {
  type    = string
  default = "bastion"
}

variable "ingress_rules_bastion" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
    security_groups  = list(string)
    self             = bool
  }))
  default = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    }
  ]
}

