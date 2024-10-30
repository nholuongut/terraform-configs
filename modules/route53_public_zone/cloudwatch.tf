# Cloud watch log group must be in us-east-1
# so we override the provider with aws.standard

resource "aws_cloudwatch_log_group" "public" {
  name = "${format("/aws/route53/%s", var.zone_name)}"
  retention_in_days = "${var.log_retention}"
  provider = "aws.standard"
  tags {
    Environment = "${terraform.workspace}"
  }
}
