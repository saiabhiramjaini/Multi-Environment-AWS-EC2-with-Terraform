variable "ami_value" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type_value" {
  description = "Instance type for the EC2 instance"
  type        = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t2.medium"
    prod    = "t2.xlarge"
  }
}

variable "subnet_id_value" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "key_name_value" {
  description = "Key pair name for the EC2 instance"
  type        = string
}


variable "s3_bucket_name" {
  description = "Name of our S3 bucket to store state file"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of our dynamodb table to prevent locking of state file"
  type        = string
}