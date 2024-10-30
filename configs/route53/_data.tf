provider "aws" {}

data "aws_region" "current" {
 current = true
}

data "aws_vpc" "selected" {
  tags {
    Environment = "${terraform.workspace}"
  }
}
