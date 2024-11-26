variable "instance_ids" {
  description = "Lista de IDs das instâncias EC2 para anexar os volumes EBS"
  type        = list(string)
}

variable "volume_sizes" {
  description = "Lista de tamanhos dos volumes EBS em GiB"
  type        = list(number)
}

variable "volume_types" {
  description = "Lista de tipos dos volumes EBS"
  type        = list(string)
  default     = ["gp2"]
}