#!/bin/bash -e
OS_PROJECT="${1:-helloworld-msa}"

# Currently needed for zipkin-mysql, since volume mounting will only be added in 1.5.0 for clusters of type 'oc cluster up'
oc login -u system:admin --insecure-skip-tls-verify
oc adm policy add-scc-to-user anyuid -z default -n "${OS_PROJECT}"

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Red Hat HelloWorld MSA (Microservice Architecture)." || true
oc project "${OS_PROJECT}"
oc policy add-role-to-user admin "system:serviceaccount:${OS_PROJECT}:turbine"

sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/" "${OS_PROJECT}.yml"
sed -i.bak "s/value: \"OS_MASTER_IP\"/value: \"$OS_MASTER_IP\"/" "${OS_PROJECT}.yml"
sed -i.bak "s/value: \"OS_PUBLIC_HOSTNAME\"/value: \"$OS_PUBLIC_HOSTNAME\"/" "${OS_PROJECT}.yml"
oc create -f "${OS_PROJECT}.yml"

sed -i.bak "s/value: \"OS_PROJECT\"/value: \"$OS_PROJECT\"/" "${OS_PROJECT}-with-zipkin.yml"
sed -i.bak "s/value: \"OS_MASTER_IP\"/value: \"$OS_MASTER_IP\"/" "${OS_PROJECT}-with-zipkin.yml"
sed -i.bak "s/value: \"OS_PUBLIC_HOSTNAME\"/value: \"$OS_PUBLIC_HOSTNAME\"/" "${OS_PROJECT}-with-zipkin.yml"
oc create -f "${OS_PROJECT}-with-zipkin.yml"

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull docker.io/metmajer/hystrix-dashboard:1.0.26.1
  sudo docker pull docker.io/metmajer/turbine-server:1.0.26.1
  sudo docker pull docker.io/metmajer/msa-aloha
  sudo docker pull docker.io/metmajer/msa-api-gateway
  sudo docker pull docker.io/metmajer/msa-bonjour
  sudo docker pull docker.io/metmajer/msa-frontend
  sudo docker pull docker.io/metmajer/msa-hola
  sudo docker pull docker.io/metmajer/msa-ola
  sudo docker pull docker.io/mysql:5.7
  sudo docker pull docker.io/openzipkin/zipkin:1.20
fi
