# Variables imported as TF_VAR_*
variable "ORG" { default = "ivytech" }
variable "SSH_KEY" { default = "bootstrap" }
variable "JOIN_DOMAIN" { default = "false" }
variable "JOIN_USER" { default = "joiner" }
variable "JOIN_PASS" { default = "little pigs little pigs let me in" }
variable "GITFS_BACKEND" { default = "false" }
variable "GITFS_REMOTE" { default = "''" }
variable "GITFS_PASSPHRASE" { default = "''" }

# Defaults
variable "max_size" { default = "1" }
variable "min_size" { default = "0" }
variable "desired_capacity" { default = "1" } 
variable "associate_public_ip_address" { default = "false" }
variable "enable_monitoring" { default = "true" }
