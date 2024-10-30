# Variables imported as TF_VAR_*
variable "ORG" { default = "ivytech" }
variable "SSH_KEY" { default = "bootstrap" }
variable "SSH_CIDR" { default = "127.0.0.1/32" }
variable "JOIN_DOMAIN" { default = "false" }
variable "JOIN_USER" { default = "joiner" }
variable "JOIN_PASS" { default = "little pigs little pigs let me in" }

# Defaults
variable "associate_public_ip_address" { default = "false" }
variable "enable_monitoring" { default = "true" }
