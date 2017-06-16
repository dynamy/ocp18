#!/bin/bash -e
OS_PROJECT="${1:-helloworld}"

if [ -z "${OS_PUBLIC_IP}" ]; then
  echo "Error: the public IP of the OpenShift master must be provided via the OS_PUBLIC_IP environment variable."
  exit 1
fi

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Red Hat HelloWorld MSA (Microservice Architecture)." || true
oc project "${OS_PROJECT}"
oc policy add-role-to-user admin "system:serviceaccount:${OS_PROJECT}:turbine"

# Install Hawkular OpenShift Agent (HOSA)
export HOSA_PROJECT=openshift-infra
oc create -f ../common/hawkular-openshift-agent-configmap.yml -n $HOSA_PROJECT
oc process -f ../common/hawkular-openshift-agent.yml -p IMAGE_VERSION=1.4.1.Final | oc create -n $HOSA_PROJECT -f -
oc adm policy add-cluster-role-to-user hawkular-openshift-agent system:serviceaccount:$HOSA_PROJECT:hawkular-openshift-agent
oc process -f ../common/hawkular-openshift-agent-project-configmap.yml | oc create -n $OS_PROJECT -f -

# Install Hawkular APM
oc process -f ../common/hawkular-apm-server.yml | oc create -n $OS_PROJECT -f -

# Install Hello World MSA Template
sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/g" "${OS_PROJECT}-with-hawkular-apm.yml"
sed -i.bak "s/value: \"OS_SUBDOMAIN\"/value: \"$OS_PUBLIC_IP.nip.io\"/g" "${OS_PROJECT}-with-hawkular-apm.yml"
sed -i.bak "s/value: \"HAWKULAR_APM_SERVICE_NAME\"/value: \"hawkular-apm\"/g" "${OS_PROJECT}-with-hawkular-apm.yml"
sed -i.bak "s/value: \"HAWKULAR_APM_PROJECT_NAME\"/value: \"openshift-infra\"/g" "${OS_PROJECT}-with-hawkular-apm.yml"
oc create -f "${OS_PROJECT}-with-hawkular-apm.yml"

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull fabric8/turbine-server:1.0.28
  sudo docker pull fabric8/hystrix-dashboard:1.0.28
  sudo docker pull gencatcloud/mysql-openshift:5.7
  sudo docker pull hawkular/hawkular-openshift-agent:1.4.1.Final
  sudo docker pull jboss/hawkular-apm-server
  sudo docker pull jpkroehling/elasticsearch
  sudo docker pull metmajer/redhatmsa-frontend
  sudo docker pull metmajer/redhatmsa-api-gateway
  sudo docker pull metmajer/redhatmsa-aloha
  sudo docker pull metmajer/redhatmsa-bonjour
  sudo docker pull metmajer/redhatmsa-hola
  sudo docker pull metmajer/redhatmsa-ola
  sudo docker pull openzipkin/zipkin:1.22
fi
