resource "aws_elb" "salt_master" {
  count = "${var.JOIN_DOMAIN == "true" ? 0 : 1 }"
  name = "salt-master-elb"
  internal = true
  subnets = [ "${data.aws_subnet_ids.selected.ids}" ]
  security_groups = [ "${data.aws_security_group.selected.id}" ]
  listener {
    instance_port     = 4505
    instance_protocol = "tcp"
    lb_port           = 4505
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = 4506
    instance_protocol = "tcp"
    lb_port           = 4506
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:4505"
    interval            = 15
  }
  tags {
    Name = "salt_master_elb"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_record" "salt_master_elb" {
  count = "${var.JOIN_DOMAIN == "true" ? 0 : 1 }"
  zone_id = "${data.aws_route53_zone.internal.zone_id}"
  name = "salt.${data.aws_route53_zone.internal.name}"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.salt_master.dns_name}" ]
}
