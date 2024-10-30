# Variables imported as TF_VAR_*
variable "ORG" { default = "ivytech" }
variable "VPN_CGW_IP" {}
variable "VPN_BGP_ASN" { default = 65000 }
variable "VPN_ROUTES" {type = "list", default = []}
