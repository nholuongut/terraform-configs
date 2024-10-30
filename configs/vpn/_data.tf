provider "aws" {}
provider "template" {}

data "aws_region" "current" {
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  tags {
    Environment = "${terraform.workspace}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "public"
  }
}

data "aws_route_table" "public" {
  count = "${length(data.aws_subnet_ids.public.ids)}"
  subnet_id = "${data.aws_subnet_ids.public.ids[count.index]}"
}

data "aws_subnet_ids" "nat" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    Type = "nat"
  }
}

data "aws_route_table" "nat" {
  count = "${length(data.aws_subnet_ids.nat.ids)}"
  subnet_id = "${data.aws_subnet_ids.nat.ids[count.index]}"
}
