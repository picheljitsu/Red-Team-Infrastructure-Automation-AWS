provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws-region
}

locals {
  #Override the defaul template if defined in tfvars, otherwise go with the default instance_template
  tvar_configs = var.instance_configs
  instance_configs = { for host, cfg in local.tvar_configs:
                        host => { for conf_key, conf_val in var.instance_template:
                          conf_key => lookup(local.tvar_configs[host], conf_key, conf_val) }
  }
  aws-sec-gp = module.firewall.id 
  server-configs = var.server-configs
  security_groups = var.security_groups
  network-configs = var.network-configs
  private-cidr = var.private-cidr
  mission-name = var.mission-name
  kms_enabled = length([for k,v in local.instance_configs: 
                          k if v.encrypted == true]) > 0 ? 1 : 0
  debug_kms = [for k,v in local.server-configs: 
                          k if v.encrypted == true]
  subnet-id = aws_subnet.red_team_subnet.id                       
  vpc-info = aws_vpc.red_team_vpc
  }

#First, have AWS generate an ssh key-pair.
module "ssh" {
  source = "./ssh"
  key_name = var.key_name
  mission-name = var.mission-name
}

# Create a VPC to launch our instances into
resource "aws_vpc" "red_team_vpc" {
  cidr_block = var.private-cidr
  tags = { 
    Name = local.mission-name
  }
}

resource "aws_subnet" "red_team_subnet" {
  vpc_id            = aws_vpc.red_team_vpc.id
  cidr_block        = var.private-cidr
  tags = {
    Name = local.mission-name
  }
}

data "aws_subnet_ids" "red_team_subnets"{
  vpc_id = aws_subnet.red_team_subnet.vpc_id
}

#This module will generate an AWS KMS key to encrypt a volume is the encrypt option provided to the instance is true
resource "aws_kms_key" "a" {
  count = local.kms_enabled
  description = "${var.mission-name} KMS key" 
}

#This module will deploy AWS instances defined in instance_configs 
module "servers" {
  source = "./servers"
  mission-name = var.mission-name
  aws-vpc-id = aws_subnet.red_team_subnet.vpc_id
  subnet_id = aws_subnet.red_team_subnet.id
  key_name = module.ssh.key_name
  aws-sec-gp = local.aws-sec-gp
  instance_configs = local.instance_configs
}

module "firewall" {
  source = "./firewall"
  vpc_id = aws_vpc.red_team_vpc.id
  security_groups = local.security_groups
}

