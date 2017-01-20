# Red Hat HelloWorld MSA (Microservice Architecture)

The [Red Hat HelloWorld MSA](https://github.com/redhat-helloworld-msa/helloworld-msa) combines a variety of technologies, such as Node, JEE, Spring Boot and Hystrix into a microservice architecture that emits "Hello World" in different languages. This application is commonly used by Red Hat consultants to demonstrate microservice deployments on OpenShift.

## Deployment

```
export OS_MASTER_IP=1.2.3.4
export OS_PROJECT=helloworld-msa

oc login https://${OS_MASTER_IP}:8443 -u developer

oc new-project ${OS_PROJECT}
oc policy add-role-to-user admin system:serviceaccount:${OS_PROJECT}:turbine
oc process -f ${OS_PROJECT}.yml -v OS_MASTER_IP=${OS_MASTER_IP} -v OS_PROJECT=${OS_PROJECT} | oc apply -f -
```

In this example, `OS_MASTER_IP` refers to the IP of your OpenShift cluster's master and has to be provided for the application's services to be properly exposed to the outside world.

After deployment, you can look up the addresses the application services are exposed at via `oc status`. A user would typically access the application via the `frontend`service.
