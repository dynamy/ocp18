#!/bin/bash -e
OS_MASTER_IP="$1"
if [ -z "$OS_MASTER_IP" ]; then
  exit 1
fi

# Run OpenShift
oc cluster up --public-hostname="$OS_MASTER_IP"
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "$USER:$USER" ~/.kube/config

# Install Dynatrace OneAgent
DT_CLUSTER="${DT_CLUSTER:-live.dynatrace.com}"
if [ -n "$DT_TENANT_ID" ] && [ -n "$DT_TENANT_TOKEN" ]; then
  wget -O Dynatrace-OneAgent.sh "https://${DT_TENANT_ID}.${DT_CLUSTER}/installer/agent/unix/latest/${DT_TENANT_TOKEN}"
  sudo /bin/sh Dynatrace-OneAgent.sh APP_LOG_CONTENT_ACCESS=1
fi

# Install OpenShift demo project
cd ~
wget https://github.com/dynatrace-innovationlab/openshift-demo-environment/archive/master.zip
unzip master.zip
cd openshift-demo-environment-master/apps

# Install OpenShift 'everest' application template
OS_PROJECT=everest
pushd ${OS_PROJECT}
oc login https://${OS_MASTER_IP}:8443 -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="A well-designed monolithic application by Arun Gupta."
oc create -f ${OS_PROJECT}.yml
popd

# Install OpenShift 'helloworld-msa' application template
OS_PROJECT=helloworld-msa
pushd ${OS_PROJECT}
oc login https://${OS_MASTER_IP}:8443 -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="The Red Hat HelloWorld MSA (Microservice Architecture)."
oc policy add-role-to-user admin system:serviceaccount:${OS_PROJECT}:turbine
oc create -f ${OS_PROJECT}.yml
popd

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd ${OS_PROJECT}
oc login https://${OS_MASTER_IP}:8443 -u system:admin
oc adm policy add-scc-to-user anyuid -z default -n ${OS_PROJECT}
oc login https://${OS_MASTER_IP}:8443 -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT} --description="The Dynatrace easyTravel sample application."
oc create -f ${OS_PROJECT}.yml
oc create -f ${OS_PROJECT}-with-loadgen.yml
popd
