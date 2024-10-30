provider "aws" {}
provider "template" {}
provider "random" {}

data "aws_region" "current" {
 current = true
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  tags {
    Environment = "${terraform.workspace}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "nat"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "public"
  }
}

data "aws_security_group" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
  name = "private"
}

data "aws_route53_zone" "internal" {
  vpc_id = "${data.aws_vpc.selected.id}"
  name = "${format("%s.%s", terraform.workspace, var.ORG)}"
  tags {
    Environment = "${terraform.workspace}"
  }
}

resource "random_string" "password" {
  length = 16
  special = true
}

data "aws_ami" "windows_2016" {
  most_recent = true
  owners = [ "801119661308" ]
  filter {
    name = "name"
    values = [ "Windows_Server-2016-English-Full-Base-*" ]
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

