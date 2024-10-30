resource "aws_vpc" "main" {
  cidr_block = "172.${var.CIDR_BLOCK}.${var.CIDR_PORTION}.0/18"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags {
    Environment = "${terraform.workspace}"
    Name = "${format("%s-%s-172.%s.%s.0-18", var.ORG, terraform.workspace, var.CIDR_BLOCK, var.CIDR_PORTION)}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Environment = "${terraform.workspace}"
  }
}

# Public subnets.  Easy Peasy.
resource "aws_subnet" "public" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block = "172.${var.CIDR_BLOCK}.${var.CIDR_PORTION + count.index}.0/24"
  tags {
    Environment = "${terraform.workspace}"
    Type = "public"
    Name = "${format("%s-public", element(data.aws_availability_zones.available.names, count.index))}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Environment = "${terraform.workspace}"
    Type = "public"
  }
}

resource "aws_route_table_association" "public" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# NATted subnets require NAT gateways and route tables.
resource "aws_eip" "nat" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  tags {
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "nat" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block = "172.${var.CIDR_BLOCK}.${var.CIDR_PORTION + 8 + count.index * 4}.0/22"
  tags {
    Environment = "${terraform.workspace}"
    Type = "nat"
    Name = "${format("%s-NAT", element(data.aws_availability_zones.available.names, count.index))}"
  }
}

resource "aws_route_table" "nat" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }
  tags {
    Environment = "${terraform.workspace}"
    Type = "public"
  }
}

resource "aws_route_table_association" "nat" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  subnet_id = "${element(aws_subnet.nat.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat.*.id, count.index)}"
}

# Private (no internet) subnets
resource "aws_subnet" "private" {
  count = "${min(length(data.aws_availability_zones.available.names), 4)}"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block = "172.${var.CIDR_BLOCK}.${var.CIDR_PORTION + 60 - count.index * 4}.0/22"
  tags {
    Environment = "${terraform.workspace}"
    Type = "private"
    Name = "${format("%s-private", element(data.aws_availability_zones.available.names, count.index))}"
  }
}
