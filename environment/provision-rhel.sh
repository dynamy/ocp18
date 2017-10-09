#!/bin/bash -e

# Install tools
sudo yum -y update
sudo yum -y install socat unzip wget

# Install docker
sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
sudo yum -y install docker-engine
sudo yum -y update
sudo service docker start

# Install docker: prepare for OpenShift
sudo sed -i 's/ExecStart=\(.*\)/ExecStart=\1 --insecure-registry 172.30.0.0\/16/' /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install oc CLI for OpenShift Origin
wget -q -O oc-linux.tar.gz https://github.com/openshift/origin/releases/download/v3.6.0/openshift-origin-client-tools-v3.6.0-c4dd4cf-linux-64bit.tar.gz
tar xvzf oc-linux.tar.gz
mv openshift-origin-client-tools-v3.6.0-c4dd4cf-linux-64bit/oc .

sudo chown root:root oc
sudo mv oc /usr/bin

sudo gpasswd -a $USER docker
newgrp docker
