module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_value         = var.ami_value
  instance_type_value = var.instance_type_value
  subnet_id_value   = var.subnet_id_value
  key_name_value    = var.key_name_value
}

module "backend" {
  source = "./modules/backend"

  s3_bucket_name = var.s3_bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}