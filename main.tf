terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "null_resource" "build_image_ami_template_packer" {
  provisioner "local-exec" {
    command = <<EOT
      packer init ./build_image_hashicorp_packer &&
      packer validate ./build_image_hashicorp_packer/amazon-linux-2.pkr.hcl &&
      packer build ./build_image_hashicorp_packer/amazon-linux-2.pkr.hcl
    EOT
  }
}

module "vpc" {
  source     = "./modules/vpc"
  vpc_name   = var.vpc_name
  cidr_block = var.cidr_block
}

module "public_subnets" {
  source                    = "./modules/public-subnets"
  subnet_count_public       = var.subnet_count_public
  vpc_id                    = module.vpc.vpc_id
  subnet_cidrs_public       = var.subnet_cidrs_public
  prefix_subnet_name_public = var.prefix_subnet_name_public
  internet_gw               = var.internet_gw
}

module "private_subnets" {
  source                     = "./modules/private-subnets"
  subnet_count_private       = var.subnet_count_private
  vpc_id                     = module.vpc.vpc_id
  subnet_cidrs_private       = var.subnet_cidrs_private
  prefix_subnet_name_private = var.prefix_subnet_name_private
  nat_gw_name                = var.nat_gw_name
  public_subnet_id           = module.public_subnets.public_subnet_ids[0]
}

module "sg_nodes_manager" {
  source         = "./modules/sg"
  sg_count       = var.sg_count_nodes_manager
  prefix_sg_name = var.prefix_sg_name_nodes_manager
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = var.ingress_rules_nodes_manager
}

module "sg_nodes_worker" {
  source         = "./modules/sg"
  sg_count       = var.sg_count_nodes_worker
  prefix_sg_name = var.prefix_sg_name_nodes_worker
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = var.ingress_rules_nodes_worker
}

module "sg_bastion" {
  source         = "./modules/sg"
  sg_count       = var.sg_count_bastion
  prefix_sg_name = var.prefix_sg_bastion
  vpc_id         = module.vpc.vpc_id
  ingress_rules  = var.ingress_rules_bastion
}

resource "aws_iam_instance_profile" "this" {
  name = "devops-lab"
  role = "AllowSSMAccessEC2"
}

data "aws_ami" "template_ami_amz2_build_packer" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["template-packer-amazon-linux-2"]
  }
  depends_on = [null_resource.build_image_ami_template_packer]
}

module "ec2_nodes_manager" {
  source               = "./modules/ec2"
  ami_id               = data.aws_ami.template_ami_amz2_build_packer.id
  instance_type        = var.node_manager_instance_type
  instance_count       = var.node_manager_instance_count
  subnet_ids           = module.private_subnets.private_subnet_ids
  key_name             = var.key_name_nodes_manager
  security_group_ids   = module.sg_nodes_manager.sg_ids
  eip_count            = var.eip_node_manager_count
  prefix_instance_name = var.node_manager_prefix_instance_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  depends_on           = [null_resource.build_image_ami_template_packer]
}

module "ebs_volumes_nodes_manager" {
  source       = "./modules/ebs"
  instance_ids = module.ec2_nodes_manager.instance_id[*]
  volume_sizes = length(module.ec2_nodes_manager.instance_id) > 0 ? tolist([for _ in module.ec2_nodes_manager.instance_id : "10"]) : []
  volume_types = ["gp3"]
  depends_on   = [module.ec2_nodes_manager]
}

module "ec2_nodes_worker" {
  source               = "./modules/ec2"
  ami_id               = data.aws_ami.template_ami_amz2_build_packer.id
  instance_type        = var.node_worker_instance_type
  instance_count       = var.node_worker_instance_count
  subnet_ids           = module.private_subnets.private_subnet_ids
  key_name             = var.key_name_nodes_workers
  security_group_ids   = module.sg_nodes_worker.sg_ids
  eip_count            = var.eip_node_worker_count
  prefix_instance_name = var.node_worker_prefix_instance_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  depends_on           = [null_resource.build_image_ami_template_packer]
}

module "ebs_volumes_nodes_worker" {
  source       = "./modules/ebs"
  instance_ids = module.ec2_nodes_worker.instance_id[*]
  volume_sizes = length(module.ec2_nodes_worker.instance_id) > 0 ? tolist([for _ in module.ec2_nodes_manager.instance_id : "10"]) : []
  volume_types = ["gp3"]
  depends_on   = [module.ec2_nodes_worker]
}

module "ec2_bastion" {
  source               = "./modules/ec2"
  ami_id               = data.aws_ami.template_ami_amz2_build_packer.id
  instance_type        = var.bastion_instance_type
  instance_count       = var.bastion_instance_count
  subnet_ids           = module.public_subnets.public_subnet_ids
  key_name             = var.key_name_bastion
  security_group_ids   = module.sg_bastion.sg_ids
  eip_count            = var.eip_bastion_count
  prefix_instance_name = var.bastion_prefix_instance_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  depends_on           = [null_resource.build_image_ami_template_packer]
}

resource "null_resource" "exec_playbooks_ansible" {
  provisioner "local-exec" {
    command = "bash $(pwd)'/scripts/playbooks-run.sh'"

    environment = {
      EXTERNAL_IP_BASTION        = module.ec2_bastion.instance_public_ip[0]
      INTERNAL_IP_NODE_MANAGER_1 = module.ec2_nodes_manager.instance_private_ip[0]
      INTERNAL_IP_NODE_MANAGER_2 = module.ec2_nodes_manager.instance_private_ip[1]
      INTERNAL_IP_NODE_MANAGER_3 = module.ec2_nodes_manager.instance_private_ip[2]
      INTERNAL_IP_NODE_WORKER_1  = module.ec2_nodes_worker.instance_private_ip[0]
      INTERNAL_IP_NODE_WORKER_2  = module.ec2_nodes_worker.instance_private_ip[1]
      INTERNAL_IP_NODE_WORKER_3  = module.ec2_nodes_worker.instance_private_ip[2]
    }
  }
  depends_on = [
    module.ec2_nodes_manager,
    module.ec2_nodes_worker
  ]
}

#### DEBUG OUTPUTs ####

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.public_subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.private_subnets.private_subnet_ids
}

output "instance_id_nodes_manager" {
  value = module.ec2_nodes_manager
}

output "instance_id_nodes_worker" {
  value = module.ec2_nodes_worker
}

output "instance_id_bastion" {
  value = module.ec2_bastion
}

output "sg_ids_nodes_manager" {
  value = module.sg_nodes_manager.sg_ids
}

output "sg_ids_nodes_worker" {
  value = module.sg_nodes_worker.sg_ids
}

output "sg_id_bastion" {
  value = module.sg_bastion.sg_ids
}

output "instance_public_ip" {
  value = module.ec2_bastion.instance_public_ip
}

output "nodes_manager_private_ip" {
  value = module.ec2_nodes_manager.instance_private_ip
}

output "nodes_worker_private_ip" {
  value = module.ec2_nodes_worker.instance_private_ip
}


