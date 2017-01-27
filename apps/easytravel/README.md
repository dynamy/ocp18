# Dynatrace easyTravel

Here's how to deploy [Dynatrace easyTravel](https://community.dynatrace.com/community/display/DL/Demo+Applications+-+easyTravel) on our [OpenShift demo environment](https://github.com/dynatrace-innovationlab/openshift-demo-environment).

## 1. Log into OpenShift

![OpenShift Web UI: Login](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-login.png)

Where username and password are 'developer' and 'developer', respectively.

## 2. Select the "easytravel" project

![OpenShift Web UI: Select Project](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-1.png)

## 3. Add to the "easytravel" project

![OpenShift Web UI: Add to Project](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-2.png)

## 4. Select the "easytravel" template from the catalog

![OpenShift Web UI: Select Template](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-3.png)

Instead of using the `easytravel` application template, you may also use `easytravel-with-loadgen`, which adds the easyTravel UEM load generator component to the application. By default, this component also enables a variety of problem patterns. Note that problem pattern activation is delayed by slightly more than 2 hours so that Dynatrace can learn from a problem-free system state first.

## 5. Create the "easytravel" application inside your project

![OpenShift Web UI: Create Application](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-4.png)

## 6. Verify that the "easytravel" application has been created

![OpenShift Web UI: Validate Creation](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-5.png)

![OpenShift Web UI: Validate Deployment](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-6.png)

![OpenShift Web UI: Validate Application](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-easytravel-7.png)

You can now access the application via the exposed route `http://www-easytravel.1.2.3.4.xip.io/`, where `1.2.3.4` refers to your cluster's (actually the cluster master's) IP address.

## Manual Deployments

Here's how to deploy the application on any OpenShift cluster. In the following examples, `OS_MASTER_IP` refers to the IP of your OpenShift cluster's master node, assuming `1.2.3.4`. Once deployed, you can access the easytravel application via the exposed route `http://www-easytravel.1.2.3.4.xip.io/`.

Instead of using the `easytravel.yml` application template, you may also use `easytravel-with-loadgen.yml` with `oc new-app`, which adds the easyTravel UEM load generator component to the application. By default, this component also enables a variety of problem patterns. Note that problem pattern activation is delayed by slightly more than 2 hours so that Dynatrace can learn from a problem-free system state first. If desired, you can have problems activated right away by setting the `ET_PROBLEMS_DELAY` environment variable in `easytravel-with-loadgen.yml` to a value of `0` or by having the variable removed from the template entirely.

### Linux / MacOS

```
export OS_MASTER_IP=1.2.3.4
export OS_PROJECT=easytravel

oc login https://${OS_MASTER_IP}:8443 -u system:admin
oc adm policy add-scc-to-user anyuid -z default -n ${OS_PROJECT}

oc login https://${OS_MASTER_IP}:8443 -u developer -p developer --insecure-skip-tls-verify
oc new-project ${OS_PROJECT}
oc new-app ${OS_PROJECT}.yml
```

### Windows

```
@echo off
set OS_MASTER_IP=1.2.3.4
set OS_PROJECT=easytravel

oc login https://%OS_MASTER_IP%:8443 -u system:admin
oc adm policy add-scc-to-user anyuid -z default -n ${OS_PROJECT}

oc login https://%OS_MASTER_IP%:8443 -u developer -p developer --insecure-skip-tls-verify
oc new-project %OS_PROJECT%
oc new-app %OS_PROJECT%.yml
```
