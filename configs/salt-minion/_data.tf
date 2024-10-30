provider "aws" {}
provider "template" {}

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

data "aws_ami" "redhat" {
  most_recent = true
  owners = [ "309956199498" ]
  filter {
    name = "name"
    values = [ "RHEL-7.4_*-x86_64-*" ]
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

data "aws_s3_bucket" "salt" {
  bucket = "${format("%s-%s-salt-%s", var.ORG, terraform.workspace, data.aws_region.current.name)}"
}
