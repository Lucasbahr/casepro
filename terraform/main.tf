
module "rede" {
  source = "./modules/rede"
  application_name = local.application_name
  aws_region = local.region
  
}

module "ec2" {
  source = "./modules/ec2"
  application_name = local.application_name
  aws_region = local.region
  subnet_id = module.rede.subnet__a_id
  aws_security_group_ssh = module.rede.aws_security_group_ssh
  aws_security_group_http = module.rede.aws_security_group_http
   
}