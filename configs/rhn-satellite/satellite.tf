data "template_file" "user_data" {
  template = "${file("user-data/satellite.sh.tpl")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${terraform.workspace}"
    REALM = "${format("%s.%s", upper(terraform.workspace), upper(var.ORG))}"
    JOIN_DOMAIN = "${var.JOIN_DOMAIN}"
    JOIN_USER = "${var.JOIN_USER}"
    JOIN_PASS = "${var.JOIN_PASS}"
  }
}

resource "aws_instance" "satellite" {
  ami                    = "${data.aws_ami.redhat.id}"
  key_name               = "${var.SSH_KEY}"
  vpc_security_group_ids = [ "${aws_security_group.satellite.id}" ]
  iam_instance_profile   = "${aws_iam_instance_profile.satellite.id}"
  subnet_id              = "${random_shuffle.subnet.result[0]}"
  user_data              = "${data.template_file.user_data.rendered}"
  instance_type          = "r4.xlarge"
  root_block_device = {
    volume_size = 12
  }
  ebs_block_device = {
    device_name = "/dev/xvdf"
    volume_type = "gp2"
    volume_size = 20
  }
  ebs_block_device = {
    device_name = "/dev/xvdg"
    volume_type = "gp2"
    volume_size = 500
  }
  ebs_block_device = {
    device_name = "/dev/xvdh"
    volume_type = "gp2"
    volume_size = 100
  }
  ebs_block_device = {
    device_name = "/dev/xvdi"
    volume_type = "gp2"
    volume_size = 20
  }
  tags {
    Name = "satellite_ec2_instance"
    Environment = "${terraform.workspace}"
  }
}
