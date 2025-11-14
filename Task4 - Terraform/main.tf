module "Task4-Network-zaeem" {
  source = "./modules/networking"
  availability_zone = var.availability_zone
  vpc_cidr = var.vpc_cidr
  subnet_cidr_A = var.subnet_cidr_A
  subnet_cidr_B = var.subnet_cidr_B
}

module "Task4-SG-Zaeem" {
  source = "./modules/sg"
  vpc_id = module.Task4-Network-zaeem.vpc_id

}

module "Task4-ECS-Zaeem" {
  source = "./modules/ecs"
  availability_zone = var.availability_zone
  vpc_cidr = var.vpc_cidr
  sg_id = module.Task4-SG-Zaeem.sg_id
  vpc_id = module.Task4-Network-zaeem.vpc_id
  public_subnet_id_A = module.Task4-Network-zaeem.public_subnet_id_A
  public_subnet_id_B = module.Task4-Network-zaeem.public_subnet_id_B
  subnet_cidr_A = var.subnet_cidr_A
  subnet_cidr_B = var.subnet_cidr_B
}
