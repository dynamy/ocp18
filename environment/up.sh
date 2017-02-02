#!/bin/bash -e
OS_MASTER_IP="$1"
OS_PUBLIC_HOSTNAME="${2:-$OS_MASTER_IP}"

if [ -z "${OS_MASTER_IP}" ]; then
  echo "The OpenShift Master IP must be provided as the first argument to up.sh. Example: ./up.sh 1.2.3.4"
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
pushd ${OS_PROJECT}
oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="A well-designed monolithic application by Arun Gupta."
oc create -f ${OS_PROJECT}.yml
popd

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull docker.io/metmajer/everest
fi

# Prepare OpenShift 'helloworld-msa' application
OS_PROJECT=helloworld-msa
pushd ${OS_PROJECT}
oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="The Red Hat HelloWorld MSA (Microservice Architecture)."
oc policy add-role-to-user admin system:serviceaccount:${OS_PROJECT}:turbine
sed -i "s/value: \"OS_MASTER_IP\"/value: \"$OS_MASTER_IP\"/" ${OS_PROJECT}.yml
sed -i "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/" ${OS_PROJECT}.yml
oc create -f ${OS_PROJECT}.yml
popd

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull docker.io/metmajer/hystrix-dashboard:1.0.26.1
  sudo docker pull docker.io/metmajer/turbine-server:1.0.26.1
  sudo docker pull docker.io/metmajer/msa-aloha
  sudo docker pull docker.io/metmajer/msa-api-gateway
  sudo docker pull docker.io/metmajer/msa-bonjour
  sudo docker pull docker.io/metmajer/msa-frontend
  sudo docker pull docker.io/metmajer/msa-hola
  sudo docker pull docker.io/metmajer/msa-ola
fi

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd ${OS_PROJECT}
oc login -u system:admin --insecure-skip-tls-verify
oc adm policy add-scc-to-user anyuid -z default -n ${OS_PROJECT}
oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="The Dynatrace easyTravel sample application."
oc create -f ${OS_PROJECT}.yml
oc create -f ${OS_PROJECT}-with-loadgen.yml
popd

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull docker.io/dynatrace/easytravel-backend
  sudo docker pull docker.io/dynatrace/easytravel-frontend
  sudo docker pull docker.io/dynatrace/easytravel-loadgen
  sudo docker pull docker.io/dynatrace/easytravel-mongodb
  sudo docker pull docker.io/dynatrace/easytravel-nginx
fi
