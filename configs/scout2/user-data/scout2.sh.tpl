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

# Meat and potatoes 

yum -y install python-pip setuptools awscli nginx
pip install awsscout2
systemctl enable nginx.service
systemctl start nginx.service

cat > /usr/local/bin/run-scout2.sh <<"EOF"
#!/bin/bash

set -e

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

ts=$$(date '+%Y%m%d')


mkdir -p /usr/share/nginx/html/archives/$$ts
Scout2 --no-browser --force --report-dir /usr/share/nginx/html/archives/$$ts --regions $$(my_aws_region)
cp -R /usr/share/nginx/html/archives/$${ts}/* /usr/share/nginx/html
rm -f /usr/share/nginx/html/index.html
ln -s /usr/share/nginx/html/report.html /usr/share/nginx/html/index.html
EOF

chmod 755 /usr/local/bin/run-scout2.sh

/usr/local/bin/run-scout2.sh

cat > /etc/cron.daily/scout2 << EOF
#!/bin/sh
/usr/local/bin/run-scout2.sh
EOF

chmod 755 /etc/cron.daily/scout2
