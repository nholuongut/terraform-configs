data "template_file" "user_data" {
  template = "${file("user-data/scout2.sh.tpl")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${terraform.workspace}"
  }
}

resource "aws_instance" "scout2" {
  ami                  = "${data.aws_ami.redhat.id}"
  key_name             = "${var.SSH_KEY}"
  vpc_security_group_ids = [ "${data.aws_security_group.selected.id}" ]
  subnet_id            = "${random_shuffle.subnet.result[0]}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.scout2.id}" 
  instance_type        = "t2.large"
  tags {
    Name = "scout2_ec2_instance"
    Environment = "${terraform.workspace}"
  }
}
