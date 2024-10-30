terraform {
  backend "s3" {
    bucket         = "ivytech-tf-state-store"
    region         = "us-east-1"
    key            = "vpn/terraform.tfstate"
    dynamodb_table = "terraform_locks"
  }
}
