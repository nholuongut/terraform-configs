resource "aws_directory_service_directory" "default" {
  name = "${data.aws_route53_zone.internal.comment}"
  password = "${random_string.password.result}"
  type = "MicrosoftAD"

  vpc_settings {
    vpc_id = "${data.aws_vpc.selected.id}"
    subnet_ids = [ "${slice(data.aws_subnet_ids.selected.ids, 0, 2)}" ]
  }
}
