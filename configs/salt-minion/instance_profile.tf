# The IAM instance profile
resource "aws_iam_instance_profile" "salt_minion" {
  name = "salt_minion_profile"
  role = "${aws_iam_role.salt_minion.name}"
}

# Which gets bound to the IAM role, with a trust
# relationship to the ec2.amazonaws.com service
resource "aws_iam_role" "salt_minion" {
  name = "salt_minion_role"
  path = "/"

  # The trusted entity in the IAM role
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# The policy statements get attached to the IAM role's
# policy, allowing instances that use sts:AssumeRole to
# use permission herein
resource "aws_iam_role_policy" "salt_minion" {
  name = "salt_minion"
  role = "${aws_iam_role.salt_minion.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "s3:ListBucket" ],
      "Resource": [ "${data.aws_s3_bucket.salt.arn}" ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [ "${data.aws_s3_bucket.salt.arn}/public/*" ]
    }
  ]
}
EOF
}
