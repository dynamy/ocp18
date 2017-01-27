# Everest: (A well-designed Monolithic Application)

The everest monolithic application is part of [Arun Gupta's microservices project](https://github.com/arun-gupta/microservices), which can be used to demonstrate a monolith-to-microservices migration: the simple, well-designed monolith can be analyzed and virtually split up into smaller services using Dynatrace's "custom services" capabilities.

Here's how to deploy this application on our [OpenShift demo environment](https://github.com/dynatrace-innovationlab/openshift-demo-environment).

## 1. Log into OpenShift

![OpenShift Web UI: Login](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-login.png)

Where username and password are 'developer' and 'developer', respectively.

## 2. Select the "everest" project

![OpenShift Web UI: Select Project](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-1.png)

## 3. Add to the "everest" project

![OpenShift Web UI: Add to Project](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-2.png)

## 4. Select the "everest" template from the catalog

![OpenShift Web UI: Select Template](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-3.png)

## 5. Create the "everest" application inside your project

![OpenShift Web UI: Create Application](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-4.png)

## 6. Verify that the "everest" application has been created

![OpenShift Web UI: Validate Creation](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-5.png)

![OpenShift Web UI: Validate Deployment](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-6.png)

![OpenShift Web UI: Validate Application](https://github.com/dynatrace-innovationlab/openshift-demo-environment/raw/images/openshift-web-ui-everest-7.png)

You can now access the application via the exposed route `http://everest-everest.1.2.3.4.xip.io/everest-1.0/`, where `1.2.3.4` refers to your cluster's (actually the cluster master's) IP address.

## Manual Deployments

Here's how to deploy the application on any OpenShift cluster. In the following examples, `OS_MASTER_IP` refers to the IP of your OpenShift cluster's master node, assuming `1.2.3.4`. Once deployed, you can access the everest application via the exposed route `http://everest-everest.1.2.3.4.xip.io/everest-1.0/`.

### Linux / MacOS

```
export OS_MASTER_IP=1.2.3.4
export OS_PROJECT=everest

oc login https://${OS_MASTER_IP}:8443 -u developer -p developer --insecure-skip-tls-verify

oc new-project ${OS_PROJECT}
oc new-app ${OS_PROJECT}.yml
```

### Windows

```
@echo off
set OS_MASTER_IP=1.2.3.4
set OS_PROJECT=everest

oc login https://%OS_MASTER_IP%:8443 -u developer -p developer --insecure-skip-tls-verify

oc new-project %OS_PROJECT%
oc new-app %OS_PROJECT%.yml
```
