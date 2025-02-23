provider "aws" {
  region = var.region
}

module "network" {
  source = "../../modules/network"
  
  environment = var.environment
  region = var.region
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
  nat_instance_eni_id = module.nat.nat_instance_eni_id
}

module "nat" {
  source = "../../modules/nat"
  
  environment = var.environment
  vpc_id = module.network.vpc_id
  vpc_cidr = var.vpc_cidr
  private_subnet_cidr = var.private_subnets[0]
  public_subnet_id = module.network.public_subnet_ids[0]
  key_name = var.key_name
}

module "alb" {
  source = "../../modules/alb"

  environment        = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  spring_instance_id = module.ec2.spring_instance_id
  flask_instance_id  = module.ec2.flask_instance_id
}

module "ec2" {
  source = "../../modules/ec2"

  environment           = var.environment
  vpc_id               = module.network.vpc_id
  private_subnet_id    = module.network.private_subnet_ids[0]
  alb_security_group_id = module.alb.alb_security_group_id
  spring_security_group_id = module.ec2.spring_security_group_id
  bastion_security_group_id = module.bastion.bastion_security_group_id
  key_name = var.key_name
}

module "bastion" {
  source = "../../modules/bastion"

  environment = var.environment
  vpc_id = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_ids[0]
  key_name = var.key_name
}