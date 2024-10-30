resource "aws_route" "datacenter_public" {
  count = "${length(distinct(data.aws_route_table.public.*.id)) * length(var.VPN_ROUTES)}"
  route_table_id = "${data.aws_route_table.public.*.id[length(distinct(data.aws_route_table.public.*.id)) - count.index % length(distinct(data.aws_route_table.public.*.id)) - 1]}"
  destination_cidr_block = "${var.VPN_ROUTES[count.index % length(data.aws_route_table.public.*.id) % length(var.VPN_ROUTES)]}"
  gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
}

resource "aws_route" "datacenter_nat" {
  count = "${length(distinct(data.aws_route_table.nat.*.id)) * length(var.VPN_ROUTES)}"
  route_table_id = "${data.aws_route_table.nat.*.id[length(distinct(data.aws_route_table.nat.*.id)) - count.index % length(distinct(data.aws_route_table.nat.*.id)) - 1]}"
  destination_cidr_block = "${var.VPN_ROUTES[count.index % length(var.VPN_ROUTES)]}"
  gateway_id = "${aws_vpn_gateway.vpn_gw.id}"
}
