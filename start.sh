#!/bin/bash
newgrp docker
cd /home/ec2-user/ocp18

export OS_PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
export OS_PUBLIC_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/public-hostname`
export OS_PULL_DOCKER_IMAGES="true"

# SET env var
OS_PUBLIC_HOSTNAME="${OS_PUBLIC_HOSTNAME:-$OS_PUBLIC_IP}"

# Run OpenShift
oc cluster up --public-hostname="${OS_PUBLIC_HOSTNAME}" --routing-suffix="${OS_PUBLIC_IP}.nip.io"
sleep 3
cd ~
mkdir ~/.kube
sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "${USER}:${USER}" ~/.kube/config
ls -al ~/.kube/config

# Add cluster-admin role to user admin
#oc login https://ec2-52-221-223-60.ap-southeast-1.compute.amazonaws.com:8443 -u system:admin
export loginserver=`echo "https://${OS_PUBLIC_HOSTNAME}:8443"`
oc login "${loginserver}" -u system:admin
oc adm policy add-cluster-role-to-user cluster-admin admin

# Add dynatrace as privileged user to the openshift-infra project
oc project openshift-infra
oc create serviceaccount dynatrace
oc adm policy add-scc-to-user privileged -z dynatrace

cd /home/ec2-user/ocp18/apps

# Install OpenShift 'easytravel' application template
OS_PROJECT=easytravel
pushd "${OS_PROJECT}"
oc adm policy add-scc-to-user anyuid -z default -n "${OS_PROJECT}"
oc login https://localhost:8443 -u developer -p developer --insecure-skip-tls-verify
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