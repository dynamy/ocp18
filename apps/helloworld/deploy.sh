#!/bin/bash -e
OS_PROJECT="${1:-helloworld}"

if [ -z "${OS_MASTER_IP}" ]; then
  echo "Error: the public IP of the OpenShift master must be provided via the OS_MASTER_IP environment variable."
  exit 1
fi

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Red Hat HelloWorld MSA (Microservice Architecture)." || true
oc project "${OS_PROJECT}"
oc policy add-role-to-user admin "system:serviceaccount:${OS_PROJECT}:turbine"

sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/" "${OS_PROJECT}.yml"
sed -i.bak "s/value: \"OS_SUBDOMAIN\"/value: \"$OS_MASTER_IP.nip.io\"/" "${OS_PROJECT}.yml"
oc create -f "${OS_PROJECT}.yml"

sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/" "${OS_PROJECT}-with-zipkin.yml"
sed -i.bak "s/value: \"OS_SUBDOMAIN\"/value: \"$OS_MASTER_IP.nip.io\"/" "${OS_PROJECT}-with-zipkin.yml"
oc create -f "${OS_PROJECT}-with-zipkin.yml"

oc create -f ../common/hawkular-apm-server-deployment.yml

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull fabric8/turbine-server:1.0.28
  sudo docker pull fabric8/hystrix-dashboard:1.0.28
  sudo docker pull gencatcloud/mysql-openshift:5.7
  sudo docker pull metmajer/redhatmsa-frontend
  sudo docker pull metmajer/redhatmsa-api-gateway
  sudo docker pull metmajer/redhatmsa-aloha
  sudo docker pull metmajer/redhatmsa-bonjour
  sudo docker pull metmajer/redhatmsa-hola
  sudo docker pull metmajer/redhatmsa-ola
  sudo docker pull openzipkin/zipkin:1.22
fi
