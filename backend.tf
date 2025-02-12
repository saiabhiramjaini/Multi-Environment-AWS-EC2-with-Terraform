terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-mumbai"
    key            = "envs/terraform.tfstate" 
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
  }
}