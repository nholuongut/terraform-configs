resource "aws_vpc_dhcp_options" "directory" {
  domain_name = "${data.aws_route53_zone.internal.comment}"
  domain_name_servers = [ "${aws_directory_service_directory.default.dns_ip_addresses}" ]
  ntp_servers = [ "169.254.169.123" ]
}

resource "aws_vpc_dhcp_options_association" "directory" {
  vpc_id = "${data.aws_vpc.selected.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.directory.id}"
}
