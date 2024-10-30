resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${data.aws_vpc.selected.id}"
  tags {
    "Name" = "${format("%s-%s-to-datacenter-vgw", terraform.workspace, data.aws_region.current.name)}"
    "Environment" = "${terraform.workspace}"
    "Purpose" = "datacenter"
  }
}
