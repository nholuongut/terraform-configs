# Variables imported as TF_VAR_*
variable "ORG" { default = "ivytech" }
variable "CIDR_BLOCK" { default = "16" }
variable "CIDR_PORTION" { default = "0" }

# SSH bastion related variablee
variable "CREATE_BASTION" { default = false }
variable "ALLOWED_SSH" { default = "127.0.0.1/32" }
variable "SSH_KEY" { default = "bootstrap" }
