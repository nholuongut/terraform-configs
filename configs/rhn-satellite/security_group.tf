resource "aws_security_group" "satellite" {
  name = "satellite"
  description = "Allow HTTP, HTTPS, AMQP from local systems"
  vpc_id = "${data.aws_vpc.selected.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [ "${var.SSH_CIDR}" ]
  }
  ingress {
    from_port = 53
    to_port = 53
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5000 
    to_port = 5000
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5646 
    to_port = 5647
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5671
    to_port = 5671
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5674
    to_port = 5674
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 8000 
    to_port = 8000
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 8140 
    to_port = 8140
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 9090 
    to_port = 9090
    protocol = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 53
    to_port = 53
    protocol = "UDP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 67
    to_port = 69 
    protocol = "UDP"
    cidr_blocks = [ "0.0.0.0/0" ]
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
    Name = "satellite_sg"
  }
} 
