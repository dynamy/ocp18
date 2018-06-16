#!/bin/bash -e
OS_PROJECT="${1:-easytravel}"

oc login -u system:admin --insecure-skip-tls-verify
oc adm policy add-scc-to-user anyuid -z default -n "${OS_PROJECT}"

oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Dynatrace easyTravel sample application." || true
oc project "${OS_PROJECT}"
oc create -f "${OS_PROJECT}".yml
oc create -f "${OS_PROJECT}"-with-loadgen.yml

if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
        sudo docker pull dynatrace/easytravel-mongodb
        sudo docker pull dynatrace/easytravel-backend
        sudo docker pull dynatrace/easytravel-frontend
        sudo docker pull dynatrace/easytravel-nginx
        sudo docker pull emperorwilson/easytravel-loadgen-dt
fi
