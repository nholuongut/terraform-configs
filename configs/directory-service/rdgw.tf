resource "aws_instance" "rdgw" {
  count = "${var.CREATE_RDGW == "true" ? 1 : 0 }"
  ami = "${data.aws_ami.windows_2016.id}"
  instance_type = "t2.small"
  key_name = "${var.SSH_KEY}"
  vpc_security_group_ids = [ "${aws_security_group.rdp.id}" ]
  subnet_id = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.directory_client.id}"
  tags {
    Name = "rdp_ec2_instance"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_ssm_association" "rdgw" {
  count = "${var.CREATE_RDGW == "true" ? 1 : 0 }"
  name = "directory_client_default_doc"
  instance_id = "${aws_instance.rdgw.id}"
  depends_on = ["aws_ssm_document.directory_client_doc", "aws_instance.rdgw"]
}
