#!/bin/bash

# move to the ec2-user directory and update yum
cd /home/ec2-user
sudo yum update -y
sudo yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel socat wget -y

# This downloads the OneAgent installer from your tenant
wget --no-check-certificate -O Dynatrace-OneAgent-Linux.sh "https://[YourDynatraceTenant]/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=[YourToken]&arch=x86&flavor=default"

# Installs One Agent
sudo /bin/sh Dynatrace-OneAgent-Linux.sh APP_LOG_CONTENT_ACCESS=1

#Install and start docker
sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum -y install docker-engine
sudo service docker start

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
sudo gpasswd -a ec2-user docker

#Clone + Enter repo
git clone https://github.com/dynamy/ocp18.git
mv /home/ec2-user/ocp18/start.sh /home/ec2-user/
chmod 755 /home/ec2-user/start.sh

export OS_PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
export OS_PUBLIC_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
export OS_PULL_DOCKER_IMAGES="true"

# SET env var
OS_PUBLIC_HOSTNAME="${OS_PUBLIC_HOSTNAME:-$OS_PUBLIC_IP}"

# Run OpenShift
cd /home/ec2-user
oc cluster up --public-hostname="${OS_PUBLIC_HOSTNAME}" --routing-suffix="${OS_PUBLIC_IP}.nip.io"
sleep 3
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig /home/ec2-user/.kube/config
sudo chown "ec2-user:ec2-user" /home/ec2-user/.kube/config

# Add cluster-admin role to user admin
#oc login https://ec2-52-221-223-60.ap-southeast-1.compute.amazonaws.com:8443 -u system:admin
export loginserver=`echo "https://${OS_PUBLIC_HOSTNAME}:8443"`
oc login "${loginserver}" -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin

# Add dynatrace as privileged user to the openshift-infra project
oc project openshift-infra
oc create serviceaccount dynatrace
oc adm policy add-scc-to-user privileged -z dynatrace

su - ec2-user -c "./start.sh"
