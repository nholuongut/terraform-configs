resource "aws_vpn_connection" "main" {
  vpn_gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
  customer_gateway_id = "${aws_customer_gateway.main.id}"
  type = "ipsec.1"
  static_routes_only = true
  tags = {
    Environment = "${terraform.workspace}"
    Purpose = "datacenter"
  }
}

resource "aws_vpn_connection_route" "datacenter" {
  count = "${length(var.VPN_ROUTES)}"
  destination_cidr_block = "${element(var.VPN_ROUTES, count.index)}"
  vpn_connection_id = "${aws_vpn_connection.main.id}"
}
