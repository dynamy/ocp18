# OpenShift Demo Environment for Dynatrace

The following combination of `Vagrantfile`, `provision.sh` and `up.sh` files allows you to quickly set up an OpenShift Origin cluster inside a virtual machine that will expose applications to the outside world. The `provision.sh` script will be executed by the `Vagrantfile`, but can also be used standalone to, e.g. set up a cluster inside a private or public cloud environment and has been tested on Ubuntu 16.04 64-bit (Xenial).

## Vagrant

[Vagrant](https://www.vagrantup.com/) is a convenience layer on top of virtualization technologies, such as VirtualBox, VMware and others, and has to be installed on your machine. The `Vagrantfile` assumes that you'll using [VirtualBox](https://www.virtualbox.org/), which is another preqrequisite.

## Deployment

Using the `vagrant up` command, Vagrant will spawn a `ubuntu/xenial64` Vagrant box from vagrantbox.es. Once the virtual machine has been launched, run `vagrant ssh` on your terminal to connect into the virtual machine via SSH.

### 1. Obtain your Public IP and Hostname

Inside the virtual machine, determine the machine's public IP address, e.g. via `ifconfig`, and take a note of it. You'll have to provide it when you invoke the `up.sh` script below, so that OpenShift can bind to it. Let's assume yor virtual machine publicly resolves to `1.2.3.4`:

```
export OS_MASTER_IP=1.2.3.4
./up.sh ${OS_MASTER_IP}
```

If you run the demo environment in a public cloud environment, such as AWS EC2 or GCE, you'll have to provide both the public IP and public hostname from your cloud backend, since otherwise routing will not work:

```
export OS_MASTER_IP=1.2.3.4
export OS_PUBLIC_HOSTNAME=mymachine.aws.amazon.com
./up.sh ${OS_MASTER_IP} ${OS_PUBLIC_HOSTNAME}
```

In addition to running OpenShift, you'll want to have your demo environment equipped with Dynatrace OneAgent for full-stack monitoring. You can do so by applying the following environment variables, before you invoke `up.sh`, where `DT_TENANT_ID` and `DT_TENANT_TOKEN` are to be taken from your Dynatrace installation and `DT_CLUSTER` is optional.

![OneAgent Installation](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/oneagent-installation.png)

```
export DT_CLUSTER="live.dynatrace.com"
export DT_TENANT_ID="..."
export DT_TENANT_TOKEN="..."
```

If you want to speed up the deployment of your sample applications, you can do so by having your OpenShift Docker registry pre-populated with the relevant Docker images by providing `OS_PULL_DOCKER_IMAGES`:

```
export OS_PULL_DOCKER_IMAGES=true
``

## Connecting

Once OpenShift is up and running, you can connect to OpenShift from both inside and outside the virtual machine using the `oc login` command or by accessing the OpenShift Web UI:

```
oc login https://1.2.3.4:8443 -u developer -p developer --insecure-skip-tls-verify
```

![OpenShift Web UI: Login](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-login.png)

Where username and password are 'developer' and 'developer', respectively.