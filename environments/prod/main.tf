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

  # use_asg 플래그에 따라 조건부 전달
  spring_instance_id = var.use_asg ? null : module.ec2.spring_instance_id
  flask_instance_id  = var.use_asg ? null : module.ec2.flask_instance_id

  spring_target_group_arns = var.use_asg ? module.ec2.spring_target_group_arns : []
  flask_target_group_arns  = var.use_asg ? module.ec2.flask_target_group_arns : []
}

module "ec2" {
  source = "../../modules/ec2"

  environment           = var.environment
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids  # 복수의 서브넷 사용
  alb_security_group_id = module.alb.alb_security_group_id
  spring_security_group_id = module.ec2.spring_security_group_id
  flask_security_group_id = module.ec2.flask_security_group_id
  bastion_security_group_id = module.bastion.bastion_security_group_id
  ec2_rds_security_group_id = module.security.ec2_rds_security_group_id
  key_name = var.key_name
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  use_asg = var.use_asg  # ASG 사용 여부 플래그
}

module "bastion" {
  source = "../../modules/bastion"

  environment = var.environment
  vpc_id = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_ids[0]
  key_name = var.key_name
}

module "rds" {
  source = "../../modules/rds"

  environment = var.environment
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  spring_security_group_id = module.ec2.spring_security_group_id
  flask_security_group_id = module.ec2.flask_security_group_id
  rds_ec2_security_group_id = module.security.rds_ec2_security_group_id

  database_name = var.database_name
  database_username = var.database_username
  database_password = var.database_password

  multi_az = true
  create_replica = true  # 레플리카 생성 플래그
}

module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id = module.network.vpc_id
}

module "elasticache" {
  source = "../../modules/elasticache"
  
  environment = var.environment
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  app_security_group_ids = [
    module.ec2.spring_security_group_id,
    module.ec2.flask_security_group_id
  ]
  
  # 옵션 파라미터
  node_type = var.elasticache_node_type
  snapshot_retention_days = var.elasticache_snapshot_retention_days
}