resource "aws_security_group" "rdp" {
  name = "default_rdp"
  description = "Allow RDP from specified CIDR blocks"
  vpc_id = "${data.aws_vpc.selected.id}"
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "TCP"
    cidr_blocks = [ "${var.ALLOWED_RDP}" ]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "default_rdp_sg"
  }
}
