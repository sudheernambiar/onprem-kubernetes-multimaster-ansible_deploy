# onprem-kubernetes-multimaster
On premise multimaster kubernetes cluster with ansible script

## Prerequisites 
- VMWare ESXi / VMS build with CentOS7 with following specs.
  - Alpha Server(Master Server 1) - Initiates kubernetes cluster starts. 
  - 3 Master servers(includes the first server). Spec: 4 cores, 8GB RAM, 56GB Disk.
  - 2 Slave Nodes. Spec: 8cores, 16GB RAM, 56GB Disk.
- git installed.
- A jump/bastien server to manage the HA enabled master 
## files explained
### k-alpha.yml
This file deals with the Ansible script on how the alpha master amount masters(where initial setup of generating admin config with VIP - Virtual IP happens). This file involves in installing needful packages, configuring ha-proxy and keepalived setips. Once the VIP been set in the cluster then the second step comes in to play.

Once initiated the multimaster cluster with pod and service network, the joining link for other masters and slave will be available. These values will be comes as k-master.yml and k-slave.yml, which will be generated automatically when we executes these scripts. These can be used when we need additional machines in to the cluster later at a point. Later applies the network with Canal and provides a layer 2 access with Metal LB ingress.

Once installation done under the folder kconf/ you can see the config file for adding another machine to access the cluster via VIP. Adding the configuration ~/.kube/config file and adding in the /etc/hosts with VIP hostname and IP will help to work it. Note that the jump server here we mentioned must need kubectl to be installed to access the cluster.

### k-master.yml
Installing the reset of all master servers with installation configurations mentioned here.

### k-slave.yml

## Procedure Steps
### ./deploy.sh


## Execution steps


## Result
