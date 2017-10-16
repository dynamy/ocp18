#!/bin/bash -e
if [ -z "${OS_PUBLIC_IP}" ]; then
  echo "Error: the public IP of the OpenShift master must be provided via the OS_PUBLIC_IP environment variable."
  exit 1
fi

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

# Install Dynatrace OneAgent
if [ -n "${ONEAGENT_INSTALLER_SCRIPT_URL}" ]; then
  wget -q -O Dynatrace-OneAgent.sh "${ONEAGENT_INSTALLER_SCRIPT_URL}"
  sudo /bin/sh Dynatrace-OneAgent.sh APP_LOG_CONTENT_ACCESS=1
fi

# Install OpenShift demo project
cd ~
wget -q -O master.zip https://github.com/dynatrace-innovationlab/openshift-demo-environment/archive/master.zip
unzip -o master.zip
cd openshift-demo-environment-master/apps

# Install OpenShift 'everest' application template
OS_PROJECT=everest
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd

# Install OpenShift 'helloworld' application template
OS_PROJECT=helloworld
pushd "${OS_PROJECT}"
./deploy-with-zipkin.sh "${OS_PROJECT}"
popd

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd "${OS_PROJECT}"
./deploy.sh "${OS_PROJECT}"
popd
