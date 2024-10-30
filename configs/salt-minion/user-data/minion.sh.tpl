#!/bin/bash

SALT_VERSION=$${SALT_VERSION:-2017.7}
ORG=${ORG}
ENV=${ENV}
REALM=${REALM}
JOIN_DOMAIN=${JOIN_DOMAIN}
JOIN_USER=${JOIN_USER}
JOIN_PASS=${JOIN_PASS}

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

yum -y install python-pip setuptools awscli

if [ "X$$JOIN_DOMAIN" == "Xtrue" ]; then
  yum -y install \
   sssd \
   realmd \
   krb5-workstation \
   oddjob \
   oddjob-mkhomedir \
   samba-common-tools \
   adcli

  echo "${JOIN_PASS}" \
   | realm join -U $${JOIN_USER}@$${REALM} $${REALM} \
     --client-software=sssd \
     --server-software=active-directory \
     --membership-software=adcli
fi

aws s3 cp s3://$${ORG}-$${ENV}-salt-$$(my_aws_region)/public/master.finger .
finger=$$(cat master.finger)

curl -L https://bootstrap.saltstack.com -o install_salt.sh
sh install_salt.sh -X stable "$$SALT_VERSION"

if [ "X$$JOIN_DOMAIN" == "Xtrue" ]; then
  echo 'master: salt' > /etc/salt/minion
else
  echo "master: salt.$${ENV}.$${ORG}}" > /etc/salt/minion
fi

cat >> /etc/salt/minion <<EOF
master_finger: $${finger}
environment: $${ENV}
pillarenv: $${ENV}
failhard: True
top_file_merging_strategy: same
EOF

cat > /etc/salt/grains <<EOF
${GRAINS}
EOF

systemctl start salt-minion.service
salt-call state.highstate 
