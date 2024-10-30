resource "aws_route53_zone" "public" {
  name = "${var.zone_name}"
  comment = "${format("Public route53 zone for %s", var.zone_name)}"
  tags { 
    Environment = "${terraform.workspace}"
  }
}

resource "aws_route53_query_log" "public" {
  depends_on = ["aws_cloudwatch_log_resource_policy.public"]
  cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.public.arn}"
  zone_id = "${aws_route53_zone.public.zone_id}"
}

output "public_zone_id" { 
  value = "${aws_route53_zone.public.zone_id}" 
  description = "Route53 hosted zone ID"
}

# https://github.com/hashicorp/terraform/issues/17156
resource "aws_route53_record" "txt" {
  name = "creator"
  type = "TXT"
  zone_id = "${aws_route53_zone.public.id}"
  ttl = 300
  records = [
    "Created by terraform"
  ]
  depends_on = [
    "aws_route53_zone.public",
    "aws_route53_query_log.public",
    "aws_cloudwatch_log_group.public"
  ]
}
