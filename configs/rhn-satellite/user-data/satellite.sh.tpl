#!/bin/bash

ORG=${ORG}
ENV=${ENV}

set -o errexit -o errtrace -o pipefail
trap signal_and_exit ERR

function my_instance_id
{
  curl -sL http://169.254.169.254/latest/meta-data/instance-id/
}

function my_az
{
  curl -sL http://169.254.169.254/latest/meta-data/placement/availability-zone/
}

function my_aws_region
{
  local az
  az=$$(my_az)
  echo "$${az%?}"
}

# Signaling that this instance is unhealthy allows AWS auto scaling to launch a copy 
# Provides for self healing and helps mitigate transient failures (e.g. package transfers)
function signal_and_exit
{
  status=$$?
  if [ $$status -gt 0 ]; then
    sleep 180 # give me a few minutes to look around before croaking
    aws autoscaling set-instance-health \
      --instance-id "$$(my_instance_id)" \
      --health-status Unhealthy \
      --region "$$(my_aws_region)"
  fi
}

#-----^ AWS safety guards ^-----

# All of this, just to install python-pip.
for i in rhscl extras optional ; do 
  yum-config-manager --enable rhui-REGION-rhel-server-$$i > /dev/null 2>&1
done

sudo rpmkeys --import https://getfedora.org/static/352C64E5.txt
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install python-pip python-setuptools awscli
yum-config-manager --disable epel

mkdir -p /tmp/ansible
for i in manifest.zip satellite.crt satellite.csr satellite.key satellite-ca.crt requirements.yml seed; do 
  aws s3 cp s3://$${ORG}-satellite-artifacts/$i /tmp/ansible/$i
done


cat > /tmp/ansible/hosts <<EOF
#!/usr/bin/python
# Meant to replace the /etc/ansible/hosts script on hosts and allow for
# local environment & role based ansible runs.

import sys
import os
import json

def main():
    inventory = {"_meta": {"hostvars": {}}}

    # Puts this host in the given HOSTGROUP
    try:
        host_group = os.environ.get("HOSTGROUP", 'default')
        inventory[host_group] = ["127.0.0.1"]
    except KeyError:
        pass

    print json.dumps(inventory)

if __name__ == '__main__':
    sys.exit(main())
EOF
chmod 755 /tmp/ansible/hosts

cat > /tmp/ansible/config.yml <<EOF
---
- hosts: satellite-server
  roles:
    - role: volumes
    - role: ntp
      ntp_server:
        - '169.254.169.123'
    - role: satellite-deployment
  vars_files:
    - "{{ satellite_deployment_vars }}"
EOF

yum -y install ansible git
cat >> /etc/ansible/ansible.cfg <<EOF
log_path = /var/log/ansible.log
EOF

cd /tmp/ansible 
ansible-galaxy install -f -r requirements.yml -p roles/
HOSTGROUP=satellite-server \
 ansible-playbook \
 -i /tmp/ansible/hosts \
 -e '{satellite_deployment_vars: /tmp/ansible/seed}' config.yml \
 --skip-tags firewall,capsule,set_network \
 -c local | tee /var/log/ansible.log 
