variable "node_worker_ami_id" {
  type    = string
  default = "ami-0c0b74d29acd0cd97"
}

variable "node_worker_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "node_worker_instance_count" {
  type    = number
  default = 3
}

variable "key_name_nodes_workers" {
  type    = string
  default = "my-key-instances-linux"
}

# variable "username_nodes_workers" {
#   type    = string
#   default = "myuser"
# }

# variable "password_nodes_workers" {
#   type      = string
#   sensitive = true
#   default   = "xxxyyyzzzkkk"
# }

variable "node_worker_prefix_instance_name" {
  type    = string
  default = "node-worker"
}

variable "eip_node_worker_count" {
  type    = number
  default = 0
}

variable "sg_count_nodes_worker" {
  type    = number
  default = 1
}

variable "prefix_sg_name_nodes_worker" {
  type    = string
  default = "swarm-nodes-worker"
}

variable "ingress_rules_nodes_worker" {
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
      from_port        = 7946
      to_port          = 7946
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 7946
      to_port          = 7946
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 4789
      to_port          = 4789
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    },
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      security_groups  = []
      self             = false
    }
  ]
}

