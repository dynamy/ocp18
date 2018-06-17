#!/bin/bash

export OS_PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
export OS_PUBLIC_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
export OS_PULL_DOCKER_IMAGES="true"

# SET env var
OS_PUBLIC_HOSTNAME="${OS_PUBLIC_HOSTNAME:-$OS_PUBLIC_IP}"

cd /home/ec2-user/ocp18/apps

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd "${OS_PROJECT}"
oc adm policy add-scc-to-user anyuid -z default -n "${OS_PROJECT}"
oc login -u developer -p developer --insecure-skip-tls-verify
oc new-project "${OS_PROJECT}" --description="The Dynatrace easyTravel sample application." || true
oc project "${OS_PROJECT}"
oc create -f "${OS_PROJECT}"-with-loadgen.yml
if [ -n "${OS_PULL_DOCKER_IMAGES}" ]; then
        sudo docker pull dynatrace/easytravel-mongodb
        sudo docker pull dynatrace/easytravel-backend
        sudo docker pull dynatrace/easytravel-frontend
        sudo docker pull dynatrace/easytravel-nginx
        sudo docker pull emperorwilson/easytravel-loadgen-dt
fi
popd
