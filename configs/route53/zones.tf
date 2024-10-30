# Examples

# module "external" { 
#   source = "../../modules/route53_public_zone"
#   zone_name = "external.ivytech.edu"
#   log_retention = 7
# }

# module "internal" {
#   source = "../../modules/route53_private_zone"
#   zone_name = "internal.ivytech.edu"
#   vpc_id = "${data.aws_vpc.selected.id}"
# }
