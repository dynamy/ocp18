#!/bin/bash

# move to the ec2-user directory and update yum
cd /home/ec2-user
yum update -y

# Paste the oneagent download link here.  THe following is an example and will not work.
# This downloads the OneAgent installer from your tenant
wget --no-check-certificate -O Dynatrace-OneAgent-Linux.sh "https://[YourDynatraceTenant]/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=[YourToken]&arch=x86&flavor=default"

# Installs One Agent
/bin/sh Dynatrace-OneAgent-Linux.sh APP_LOG_CONTENT_ACCESS=1

#Install and start docker
yum install docker -y
service docker start

#install git
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel socat unzip -y

# Install docker: prepare for OpenShift
sudo sed -i 's/ExecStart=\(.*\)/ExecStart=\1 --insecure-registry 172.30.0.0\/16/' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install oc CLI for OpenShift Origin
wget -q -O oc-linux.tar.gz https://github.com/openshift/origin/releases/download/v3.7.2/openshift-origin-client-tools-v3.7.2-282e43f-linux-64bit.tar.gz
tar xvzf oc-linux.tar.gz
mv openshift-origin-client-tools-v3.7.2-282e43f-linux-64bit/oc .

sudo chown root:root oc
sudo mv oc /usr/bin

sudo gpasswd -a $USER docker
newgrp docker

#Clone + Enter repo
git clone https://github.com/dynamy/ocp18.git
cd /home/ec2-user/ocp18

#export OS_PUBLIC_IP="1.2.3.4"
#export OS_PUBLIC_HOSTNAME="openshift.acmeco.com"

#curl http://169.254.169.254/latest/meta-data/public-hostname
#curl http://169.254.169.254/latest/meta-data/public-ipv4

# SET env var
OS_PUBLIC_HOSTNAME="${OS_PUBLIC_HOSTNAME:-$OS_PUBLIC_IP}"

# Run OpenShift
oc cluster up --public-hostname="${OS_PUBLIC_HOSTNAME}" --routing-suffix="${OS_PUBLIC_IP}.nip.io"
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "${USER}:${USER}" ~/.kube/config

# Add cluster-admin role to user admin
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin

# Add dynatrace as privileged user to the openshift-infra project
oc project openshift-infra
oc create serviceaccount dynatrace
oc adm policy add-scc-to-user privileged -z dynatrace

cd /home/ec2-user/ocp18/apps

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd
