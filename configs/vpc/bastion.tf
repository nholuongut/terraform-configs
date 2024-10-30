resource "aws_instance" "bastion" {
  count = "${var.CREATE_BASTION == "true" ? 1 : 0 }"
  ami = "${data.aws_ami.amazon.id}"
  instance_type = "t2.micro"
  key_name = "${var.SSH_KEY}"
  vpc_security_group_ids = [ "${aws_security_group.ssh.id}" ]
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  associate_public_ip_address = true
  tags {
    Name = "bastion_ec2_instance"
    Environment = "${terraform.workspace}"
  }
}
