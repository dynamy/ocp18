#!/bin/bash -e
OS_PROJECT="${1:-everest}"

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="A well-designed monolithic application by Arun Gupta." || true
oc project "${OS_PROJECT}"
oc create -f "${OS_PROJECT}.yml"

oc create -f ../common/hawkular-apm-server-deployment.yml

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
  sudo docker pull docker.io/metmajer/everest
fi
