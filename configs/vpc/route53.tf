resource "aws_route53_zone" "main" {
  name = "${format("%s.%s", terraform.workspace, var.ORG)}"
  comment = "${format("%s.%s", terraform.workspace, var.ORG)}"
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Environment = "${terraform.workspace}"
  }
}
