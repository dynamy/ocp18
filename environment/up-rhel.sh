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

oc project openshift-infra
oc create serviceaccount dynatrace
oc adm policy add-scc-to-user privileged -z dynatrace