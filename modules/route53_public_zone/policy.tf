data "aws_iam_policy_document" "route53_query_logging_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "public" {
  policy_document = "${data.aws_iam_policy_document.route53_query_logging_policy.json}"
  policy_name     = "route53-query-logging-policy-${replace(var.zone_name, ".", "_")}"
  provider = "aws.standard"
}
