packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "template-packer-amazon-linux-2"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "volume_size" {
  type    = string
  default = "10"
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "ansible_python_interpreter" {
  type    = string
  default = "/usr/bin/python3"
}

data "amazon-ami" "amz2_ami_template" {
  filters = {
    name                = "amzn2-ami-hvm-*-x86_64-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["137112412989"]
  profile     = "${var.aws_profile}"
  region      = "${var.aws_region}"
}

source "amazon-ebs" "amz2_ami_template" {
  ami_description             = "Amazon Linux 2 AMI built with Packer"
  ami_name                    = "${var.ami_name}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_type}"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
  profile      = "${var.aws_profile}"
  region       = "${var.aws_region}"
  source_ami   = "${data.amazon-ami.amz2_ami_template.id}"
  ssh_username = "${var.ssh_user}"
}

build {
  sources = ["source.amazon-ebs.amz2_ami_template"]

  provisioner "ansible" {
    command                 = "ansible-playbook"
    playbook_file           = "./build_image_hashicorp_packer/scripts/playbook-updateOS.yml"
    user                    = "${var.ssh_user}"
    inventory_file_template = "instance-build-packer-temp ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_python_interpreter=${var.ansible_python_interpreter}"
  }

  provisioner "shell" {
    script = "./build_image_hashicorp_packer/scripts/hardeningOS.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo timedatectl set-timezone America/Sao_Paulo",
      "sudo timedatectl set-ntp true",
      "sudo hostnamectl set-hostname hardening-os-amz2-default"
    ]
  }

}

