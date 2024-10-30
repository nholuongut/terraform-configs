# The IAM instance profile
resource "aws_iam_instance_profile" "satellite" {
  name = "satellite_profile"
  role = "${aws_iam_role.satellite.name}"
}

# Which gets bound to the IAM role, with a trust
# relationship to the ec2.amazonaws.com service
resource "aws_iam_role" "satellite" {
  name = "satellite_role"
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
resource "aws_iam_role_policy" "satellite" {
  name = "satellite"
  role = "${aws_iam_role.satellite.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "s3:ListBucket" ],
      "Resource": [ "${data.aws_s3_bucket.satellite.arn}" ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [ "${data.aws_s3_bucket.satellite.arn}/*" ]
    }
  ]
}
EOF
}
