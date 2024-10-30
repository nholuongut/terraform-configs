provider "aws" {}

data "aws_region" "current" {
 current = true
}

data "aws_availability_zones" "available" {}

data "aws_ami" "amazon" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn-ami-*-*-x86_64-*" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
}

