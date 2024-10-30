#!/bin/bash

SALT_VERSION=$${SALT_VERSION:-2017.7}
ORG=${ORG}
ENV=${ENV}
REALM=${REALM}
JOIN_DOMAIN=${JOIN_DOMAIN}
JOIN_USER=${JOIN_USER}
JOIN_PASS='${JOIN_PASS}'
GITFS_BACKEND=${GITFS_BACKEND}
GITFS_REMOTE=${GITFS_REMOTE}
GITFS_PASSPHRASE=${GITFS_PASSPHRASE}

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

yum -y install \
        python-pip \
        systemd-python \
        awscli

if [ "X$$JOIN_DOMAIN" == "Xtrue" ]; then
  yum -y install \
   sssd \
   realmd \
   krb5-workstation \
   oddjob \
   oddjob-mkhomedir \
   samba-common-tools \
   adcli

  hostnamectl set-hostname salt.$${ENV}.$${ORG}

  echo "$${JOIN_PASS}" \
   | realm join -U $${JOIN_USER}@$${REALM} $${REALM} \
     --client-software=sssd \
     --server-software=active-directory \
     --membership-software=adcli \
     --computer-name=salt
fi

aws s3 cp s3://$${ORG}-$${ENV}-salt-$$(my_aws_region)/master/master.pem /tmp/master.pem
aws s3 cp s3://$${ORG}-$${ENV}-salt-$$(my_aws_region)/master/master.pub /tmp/master.pub

# open file descriptor limit
cat >> /etc/security/limits.conf <<EOF
root    soft    nofile  65536
root    hard    nofile  65536
EOF

# Hosts file so that the minion doesn't complain.
sed -i -e '/127.0.0.1/s/$$/ salt/' /etc/hosts

curl -sL https://bootstrap.saltstack.com -o install_salt.sh
sh install_salt.sh -M stable "$$SALT_VERSION"

mv /tmp/master.pem /tmp/master.pub /etc/salt/pki/master
chown -R root:root /etc/salt/pki/master
chmod go-rwx /etc/salt/pki/master/master.pem

cat > /etc/salt/master <<"EOF"
# Configured from AWS user-data.  
# See https://github.com/saltstack/salt/blob/develop/conf/master

# Each minion connecting to the master uses AT LEAST one file descriptor, the
# master subscription connection. If enough minions connect you might start
# seeing on the console (and then salt-master crashes):
#   Too many open files (tcp_listener.cpp:335)
#   Aborted (core dumped)
max_open_files: 65536

# Enable auto_accept, this setting will automatically accept all incoming
# public keys from the minions. Note that this is insecure.
auto_accept: True

# Use TLS/SSL encrypted connection between master and minion.
# Can be set to a dictionary containing keyword arguments corresponding to Python's
# 'ssl.wrap_socket' method.
# Default is None.
#ssl:
#    keyfile: <path_to_keyfile>
#    certfile: <path_to_certfile>
#    ssl_version: PROTOCOL_TLSv1_2

# The failhard option tells the minions to stop immediately after the first
# failure detected in the state execution, defaults to False
failhard: True

# The level of messages to send to the console.
# One of 'garbage', 'trace', 'debug', info', 'warning', 'error', 'critical'.
log_level: info
EOF

if [ "X$$GITFS_BACKEND" == "Xtrue" ]; then
  yum -y install python-pygit2 git python-dulwich
  mkdir /etc/salt/gitfs
  aws s3 cp s3://$${ORG}-$${ENV}-salt-$$(my_aws_region)/master/gitfs.pem /etc/salt/gitfs/gitfs.pem
  aws s3 cp s3://$${ORG}-$${ENV}-salt-$$(my_aws_region)/master/gitfs.pub /etc/salt/gitfs/gitfs.pub
  chown -R root:root /etc/salt/gitfs
  chmod -R go-rwx /etc/salt/gitfs

  cat >> /etc/salt/master <<EOF
fileserver_backend:
  - git
gitfs_pubkey: /etc/salt/gitfs/gitfs.pub
gitfs_privkey: /etc/salt/gitfs/gitfs.pem
gitfs_passphrase: $${GITFS_PASSPHRASE}
gitfs_root: salt
gitfs_saltenv:
  - dev:
    - ref: develop
  - test:
    - ref: test
  - staging:
    - ref: staging
  - prod:
    - ref: prod
gitfs_remotes:
  - $${GITFS_REMOTE}
ext_pillar:
  - git:
    - develop $${GITFS_REMOTE}:
      - root: pillar/dev
      - privkey: /etc/salt/gitfs/gitfs.pem
      - pubkey: /etc/salt/gitfs/gitfs.pub
      - env: dev
    - test $${GITFS_REMOTE}:
      - root: pillar/test
      - privkey: /etc/salt/gitfs/gitfs.pem
      - pubkey: /etc/salt/gitfs/gitfs.pub
      - env: test
    - staging $${GITFS_REMOTE}:
      - root: pillar/staging
      - privkey: /etc/salt/gitfs/gitfs.pem
      - pubkey: /etc/salt/gitfs/gitfs.pub
      - env: staging
    - prod $${GITFS_REMOTE}:
      - root: pillar/prod
      - privkey: /etc/salt/gitfs/gitfs.pem
      - pubkey: /etc/salt/gitfs/gitfs.pub
      - env: prod
EOF
fi

systemctl restart salt-master.service
systemctl restart salt-minion.service
