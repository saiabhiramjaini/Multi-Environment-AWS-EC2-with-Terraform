resource "aws_instance" "ec2" {
  ami           = var.ami_value
  instance_type = lookup(var.instance_type_value, terraform.workspace)
  subnet_id     = var.subnet_id_value
  key_name      = var.key_name_value
}