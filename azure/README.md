OpenShift Origin on Azure
=

This folder contains resources that allow for easy deployment of an OpenShift environment on Azure VMs.
For now, it is just an exported ARM template of a manually built installation.

The ARM template is based on an Ubuntu-16.04 LTS VM and contains the following inbound security rules:
* SSH: Port 22
* OpenShift Portal: Port 8443
* EasyTravel Frontend: Port 80
* EasyTravel Administration: Port 8080

The folder 'arm' contains the ARM template and several script files for triggering the deployment:
* PowerShell: deploy.ps1
* Bash: deploy.sh
* Ruby: deployer.rb
* C#: DeploymentHelper.cs

