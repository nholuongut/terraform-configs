resource "aws_customer_gateway" "main" {
  bgp_asn = "${var.VPN_BGP_ASN}"
  ip_address = "${var.VPN_CGW_IP}"
  type = "ipsec.1"
  tags = {
    Environment = "${terraform.workspace}"
    Name = "${format("datacenter-to-%s-%s-cgw", terraform.workspace, data.aws_region.current.name)}"
    Purpose = "datacenter"
  }
}
