# Everest: (A well-designed Monolithic Application)

The everest monolithic application is part of [Arun Gupta's microservices project](https://github.com/arun-gupta/microservices), which demonstrates a monolith to microservices migration use-case. Everest is simple, well-designed monolithic, which can be analyzed and virtually split up into smaller services using Dynatrace's "custom services" capabilities.

## Deployment

```
export OS_PROJECT=everest

oc login https://$OS_MASTER_IP -u developer

oc new-project "$OS_PROJECT"
oc create -f "$OS_PROJECT.yml"
```
