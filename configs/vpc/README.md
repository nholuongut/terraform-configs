## Initializing

If there is no backend_config.tf file, then run ../state/create_backend.sh from this directory.

Next, run 'terraform init'

## terraform plan / terraform apply
To create a VPC with a publicly accessible SSH bastion:

```
TF_VAR_ALLOWED_SSH=0.0.0.0/0 \
TF_VAR_CIDR_BLOCK=30 \
TF_VAR_CREATE_BASTION=true \
TF_VAR_SSH_KEY=mykey \
terraform apply .
```

If SSH ain't your thing:

```
terraform apply .
```

There are a few other environment variables

##SSH Keys

I didn't deal with SSH keys because they look clunky with terraform (for right now).  Just generate a key pair in the EC2 management console called "bootstrap."
