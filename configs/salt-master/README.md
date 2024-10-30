# Salt master terraform template

This template creates a Salt master, with access to an S3 bucket that contains its
public and private Salt keys.  Depending on environment variables, it may join itself
to a directory service like AWS's implementation of Microsoft AD.

## Environment variables

| Name               | Purpose                                                  | Default   |
|--------------------|----------------------------------------------------------|-----------|
| TF_VAR_ORG         | Your company or organization name                        | None      |
| TF_VAR_ENV         | The environment you're working on (e.g. dev, test, prod) | None      |
| TF_VAR_JOIN_DOMAIN | Set to 'true' to join this EC2 instance to a domain      | blank     |
| TF_VAR_JOIN_USER   | The username of a joiner account                         | blank     |
| TF_VAR_JOIN_PASS   | The password for the joiner account                      | blank     |
| TF_VAR_SSH_KEY     | The SSH key used to log into new EC2 instances           | bootstrap |

### Using environment variables

Simply prepend your terraform command, e.g.:

```
TF_VAR_ORG=example TF_VAR_ENV=dev TF_VAR_JOIN_DOMAIN=true TF_VAR_JOIN_USER=user TF_VAR_JOIN_PASS=pass terrraform plan . 
```
