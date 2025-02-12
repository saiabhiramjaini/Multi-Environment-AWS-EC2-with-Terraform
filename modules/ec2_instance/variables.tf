variable "ami_value" {
  description = "Value for AMI"
  type        = string
}

variable "instance_type_value" {
  description = "Instance type for the EC2 instance"
  type        = map(string)
}

variable "subnet_id_value" {
  description = "Value for subnet id"
  type        = string
}

variable "key_name_value" {
  description = "Value for Key"
  type        = string
}