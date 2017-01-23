# OpenShift Demo Environment for Dynatrace

The following combination of `Vagrantfile`, `provision.sh` and `up.sh` files allows you to quickly set up an OpenShift Origin cluster inside a virtual machine that will expose applications to the outside world. The `provision.sh` script will be executed by the `Vagrantfile`, but can also be used standalone to, e.g. set up a cluster inside a private or public cloud environment and has been tested on Ubuntu 16.04 64-bit (Xenial).

## Vagrant

[Vagrant](https://www.vagrantup.com/) is a convenience layer on top of virtualization technologies, such as VirtualBox, VMware and others, and has to be installed on your machine. The `Vagrantfile` assumes that you'll using [VirtualBox](https://www.virtualbox.org/), which is another preqrequisite.

## Deployment

The following `vagrant up` command will spawn a `ubuntu/xenial64` Vagrant box from vagrantbox.es.

```
vagrant up
```

Once the virtual machine has been launched, you have to `vagrant ssh` into the box and obtain the virtual machine's public IP via `ifconfig`. Then, apply this IP address to the provided `up.sh` script to prepare OpenShift like so:

```
./up.sh "1.2.3.4"
```

In addition to running OpenShift, you most probably want to have your demo environment equipped with Dynatrace OneAgent for full-stack monitoring. You can do so by applying the following environment variables, where `DT_TENANT_ID` and `DT_TENANT_TOKEN` are to be taken from your Dynatrace installation:

```
export DT_CLUSTER="live.dynatrace.com"
export DT_TENANT_ID="..."
export DT_TENANT_TOKEN="..."

./up.sh "1.2.3.4"
```
