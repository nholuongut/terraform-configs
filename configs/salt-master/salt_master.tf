data "template_file" "user_data" {
  template = "${file("user-data/master.sh.tpl")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${terraform.workspace}"
    REALM = "${format("%s.%s", upper(terraform.workspace), upper(var.ORG))}"
    JOIN_DOMAIN = "${var.JOIN_DOMAIN}"
    JOIN_USER = "${var.JOIN_USER}"
    JOIN_PASS = "${var.JOIN_PASS}"
    GITFS_BACKEND = "${var.GITFS_BACKEND}"
    GITFS_REMOTE="${var.GITFS_REMOTE}"
    GITFS_PASSPHRASE="${var.GITFS_PASSPHRASE}"
  }
}

resource "aws_launch_configuration" "salt_master" {
  name_prefix                 = "salt_master"
  instance_type               = "t2.micro"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  iam_instance_profile        = "${aws_iam_instance_profile.salt_master.id}" 
  security_groups             = [ "${data.aws_security_group.selected.id}" ]
  user_data                   = "${data.template_file.user_data.rendered}"
  key_name                    = "${var.SSH_KEY}"
  image_id                    = "${data.aws_ami.redhat.id}"
  enable_monitoring           = "${var.enable_monitoring}"
  lifecycle { 
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "salt_master" {
  name                 = "salt_master_asg"
  availability_zones   = [ "${data.aws_availability_zones.available.names}" ]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.salt_master.id}"
  vpc_zone_identifier  = [ "${data.aws_subnet_ids.selected.ids}" ]
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key =  "Name"
    value = "salt-master_asg_instance"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${terraform.workspace}"
    propagate_at_launch = true
  }
  tag {
    key = "Purpose"
    value = "salt"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "salt_master_elb" {
  count = "${var.JOIN_DOMAIN == "true" ? 0 : 1 }"
  autoscaling_group_name = "${aws_autoscaling_group.salt_master.id}"
  elb = "${aws_elb.salt_master.id}"
}

output "autoscaling_group_arn" {
  value = "${aws_autoscaling_group.salt_master.arn}"
}

output "autoscaling_group_name" {
  value = "${aws_autoscaling_group.salt_master.id}"
}
