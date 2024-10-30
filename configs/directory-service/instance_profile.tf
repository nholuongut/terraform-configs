# The IAM instance profile
resource "aws_iam_instance_profile" "directory_client" {
  name = "directory_client_profile"
  role = "${aws_iam_role.directory_client.name}"
}

# Which gets bound to the IAM role, with a trust
# relationship to the ec2.amazonaws.com service
resource "aws_iam_role" "directory_client" {
  name = "directory_client_role"
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

# Attach a managed AWS  policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm" {
  role = "${aws_iam_role.directory_client.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
