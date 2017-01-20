OS_MASTER_IP="$1"

if [ -z "$OS_MASTER_IP" ]; then
  exit 1
fi

# Run OpenShift cluster
oc cluster up --public-hostname="$OS_MASTER_IP"

sudo cp /var/lib/origin/openshift.local.config/master/admin.kubeconfig ~/.kube/config
sudo chown "$USER:$USER" ~/.kube/config

# Configure OpenShift to allow container processes to run as user "root"
oc adm policy add-scc-to-user anyuid -z default
