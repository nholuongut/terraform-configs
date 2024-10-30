resource "aws_route53_zone" "private" {
  name = "${var.zone_name}"
  comment = "${format("Private route53 zone for %s", var.zone_name)}"
  vpc_id = "${var.vpc_id}"
  tags { 
    Environment = "${terraform.workspace}"
  }
}

output "private_zone_id" { 
  value = "${aws_route53_zone.private.zone_id}" 
  description = "Route53 hosted zone ID"
}

# https://github.com/hashicorp/terraform/issues/17156
resource "aws_route53_record" "txt" {
  name = "creator"
  type = "TXT"
  zone_id = "${aws_route53_zone.private.id}"
  ttl = 300
  records = [
    "Created by terraform"
  ]
  depends_on = [ "aws_route53_zone.private" ]
}
