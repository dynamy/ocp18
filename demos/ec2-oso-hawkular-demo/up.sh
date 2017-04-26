#!/bin/bash -e
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv \
           --keyserver hkp://ha.pool.sks-keyservers.net:80 \
           --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Install Dynatrace OneAgent
DT_CLUSTER="${DT_CLUSTER:-live.dynatrace.com}"
if [ -n "${DT_TENANT_ID}" ] && [ -n "${DT_TENANT_TOKEN}" ]; then
  wget -q -O Dynatrace-OneAgent.sh "https://${DT_TENANT_ID}.${DT_CLUSTER}/installer/agent/unix/latest/${DT_TENANT_TOKEN}"
  sudo /bin/sh Dynatrace-OneAgent.sh APP_LOG_CONTENT_ACCESS=1
  sleep 120
fi

# Install tools
sudo apt-get update
sudo apt-get install -y socat unzip

# Install docker
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install -y docker-engine=1.12.3-0~xenial
sudo service docker start

# Install docker: prepare for OpenShift
if ! grep -e '--insecure-registry 172.30.0.0/16' /lib/systemd/system/docker.service &>/dev/null; then
  sudo sed -i 's/ExecStart=\(.*\)/ExecStart=\1 --insecure-registry 172.30.0.0\/16/' /lib/systemd/system/docker.service
fi

sudo sed -i 's/SocketMode=\(.*\)/SocketMode=0666/' /lib/systemd/system/docker.socket
sudo systemctl daemon-reload
sudo systemctl restart docker

# Install oc CLI
cd ~
wget -q -O oc-linux.tar.gz https://github.com/openshift/origin/releases/download/v3.6.0-alpha.0/openshift-origin-client-tools-v3.6.0-alpha.0-0343989-linux-64bit.tar.gz
tar xvzf oc-linux.tar.gz
mv openshift-origin-client-tools-v3.6.0-alpha.0-0343989-linux-64bit/oc .

sudo chown root:root oc
sudo mv oc /usr/bin

# Run OpenShift
export OS_PUBLIC_IP=$(wget -q -O- http://instance-data/latest/meta-data/public-ipv4)
export OS_PUBLIC_HOSTNAME=$(wget -q -O- http://instance-data/latest/meta-data/public-hostname)

oc cluster up --public-hostname="${OS_PUBLIC_HOSTNAME}" --routing-suffix="${OS_PUBLIC_IP}.nip.io" --logging --metrics
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "${USER}:${USER}" ~/.kube/config

# Add cluster-admin role to user admin
oc login -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin

# Install OpenShift demo project
cd ~
wget -q -O master.zip https://github.com/dynatrace-innovationlab/openshift-demo-environment/archive/master.zip
unzip -o master.zip
cd openshift-demo-environment-master/apps

# Install Hawkular
export HAWKULAR_PROJECT=openshift-infra

# Install Hawkular OpenShift Agent (HOSA)
oc create -f common/hawkular-openshift-agent-configmap.yml -n $HAWKULAR_PROJECT
oc process -f common/hawkular-openshift-agent.yml -p IMAGE_VERSION=1.4.1.Final | oc create -n $HAWKULAR_PROJECT -f -
oc adm policy add-cluster-role-to-user hawkular-openshift-agent system:serviceaccount:$HAWKULAR_PROJECT:hawkular-openshift-agent

oc create -f common/hawkular-openshift-agent-project-configmap.yml -n openshift

# Install Hawkular APM
oc create -f common/hawkular-apm-server.yml -n openshift

# Install OpenShift 'helloworld' application template
OS_PROJECT=helloworld
pushd "${OS_PROJECT}"
./deploy-with-hawkular-apm.sh "${OS_PROJECT}"
popd
