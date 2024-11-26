variable "ami_id" {
  type    = string
  default = "value"
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "security_group_ids" {
  type = list(string)
}

variable "prefix_instance_name" {
  type = string
}

# variable "username" {
#   type = string
# }

# variable "password" {
#   type      = string
#   sensitive = true
# }

variable "subnet_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "eip_count" {
  type = number
}

variable "iam_instance_profile" {
  type = string
}
