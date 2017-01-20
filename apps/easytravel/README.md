# Dynatrace easyTravel

## Prerequisites

By default, processes inside a Docker container run as user `root`. Being a secure container platform, OpenShift won't allow you doing so by default. By widening OpenShift's *securty context constraints*, you can run [Dockerized easyTravel](https://github.com/dynatrace-innovationlab/easyTravel-OpenShift) on OpenShift, despite its various processes running as `root`:

```
export OS_MASTER_IP=1.2.3.4
export OS_PROJECT=easytravel

oc login https://${OS_MASTER_IP}:8443 -u system:admin
oc adm policy add-scc-to-user anyuid -z default -n ${OS_PROJECT}
```

## Deployment

```
export OS_MASTER_IP=1.2.3.4
export OS_PROJECT=easytravel

oc login https://${OS_MASTER_IP}:8443 -u developer

oc new-project ${OS_PROJECT}
oc new-app ${OS_PROJECT}.yml
```

Instead of using the `easytravel.yml` application template, you may also use `easytravel-with-loadgen.yml`, which adds the easyTravel loadgen component to the application, and by default, enables a variety of problem patterns for your convenience.

Note: in this template, the problem pattern activation is delayed by slightly more than 2 hours so that, in a Dynatrace use case, Dynatrace can learn from a problem-free state so that problems can be accurately identified as such. If so desired, you can have problems activated right away by setting `ET_PROBLEMS_DELAY` to a value of 0 or by removing the variable from the template entirely.
