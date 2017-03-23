#!/bin/bash -e
export OS_PUBLIC_HOSTNAME="${OS_PUBLIC_HOSTNAME:-$OS_MASTER_IP}"

if [ -z "${OS_MASTER_IP}" ]; then
  echo "Error: the OpenShift Master IP must be provided via the OS_MASTER_IP environment variable."
  exit 1
fi

# Run OpenShift
oc cluster up --public-hostname="${OS_PUBLIC_HOSTNAME}" --routing-suffix="${OS_MASTER_IP}.xip.io"

sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "${USER}:${USER}" ~/.kube/config

# Install Dynatrace OneAgent
DT_CLUSTER="${DT_CLUSTER:-live.dynatrace.com}"
if [ -n "${DT_TENANT_ID}" ] && [ -n "${DT_TENANT_TOKEN}" ]; then
  wget -q -O Dynatrace-OneAgent.sh "https://${DT_TENANT_ID}.${DT_CLUSTER}/installer/agent/unix/latest/${DT_TENANT_TOKEN}"
  sudo /bin/sh Dynatrace-OneAgent.sh APP_LOG_CONTENT_ACCESS=1
fi

# Install OpenShift demo project
cd ~
wget -q -O master.zip https://github.com/dynatrace-innovationlab/openshift-demo-environment/archive/master.zip
unzip -o master.zip
cd openshift-demo-environment-master/apps

# Prepare OpenShift 'everest' application
OS_PROJECT=everest
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd

# Prepare OpenShift 'helloworld-msa' application
OS_PROJECT=helloworld-msa
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd
