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
Installing the rest of all master servers with installation configurations mentioned here. In this setup along with alpha master those master configuration joining string also executed. haproxy as well as keepalived also configured with coresponding network interface and priority number.(these special values been entered in pilot mode during ansible script execution (./deploy.sh).

The rest of network configuration and other settings will automatically replicated in this master machine as well.

### k-slave.yml
This ansible script adds a kubernetes slave machine with the necessary packages as well as settings in the machine. the slave/worker node joining string will be executed and confirms the addition of this worker node. 

### Files under templates/
Following will be added to the recipient machines.
cat remote_hosts.tmpl
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
#Local Kubernetes entries
{{ vip }}  {{ vip_hostname}}
{{ master1_ip }}   {{ master1_hostname }}
{{ master2_ip }}   {{ master2_hostname }}
{{ master3_ip }}   {{ master3_hostname }}
{{ node1_ip }}   {{ node1_name }}
{{ node2_ip }}   {{ node2_name }}

### Files under vars
related to alpha, master and metallb related values resides here.

## Verify the status
Once added all machines in we can see node details.
```
$ kubectl get nodes
NAME           STATUS   ROLES                  AGE   VERSION
k8s-master-1   Ready    control-plane,master   20d   v1.23.6
k8s-master-2   Ready    control-plane,master   20d   v1.23.6
k8s-master-3   Ready    control-plane,master   20d   v1.23.6
k8s-node-1     Ready    <none>                 20d   v1.23.6
k8s-node-2     Ready    <none>                 20d   v1.23.6
```

While checking the kube system we will get following, 
```
kubectl get all -n kube-system
NAME                                          READY   STATUS    RESTARTS      AGE
pod/calico-kube-controllers-7c845d499-f8wbx   1/1     Running   0             20d
pod/canal-7p8lw                               2/2     Running   0             20d
pod/canal-7z6sq                               2/2     Running   0             20d
pod/canal-kdhj6                               2/2     Running   0             20d
pod/canal-qdndv                               2/2     Running   0             20d
pod/canal-w76rl                               2/2     Running   0             20d
pod/coredns-64897985d-9c9ss                   1/1     Running   0             20d
pod/coredns-64897985d-h6bvr                   1/1     Running   0             20d
pod/etcd-k8s-master-1                         1/1     Running   0             20d
pod/etcd-k8s-master-2                         1/1     Running   0             20d
pod/etcd-k8s-master-3                         1/1     Running   0             20d
pod/kube-apiserver-k8s-master-1               1/1     Running   0             20d
pod/kube-apiserver-k8s-master-2               1/1     Running   0             20d
pod/kube-apiserver-k8s-master-3               1/1     Running   0             20d
pod/kube-controller-manager-k8s-master-1      1/1     Running   1 (20d ago)   20d
pod/kube-controller-manager-k8s-master-2      1/1     Running   0             20d
pod/kube-controller-manager-k8s-master-3      1/1     Running   0             20d
pod/kube-proxy-5k7d7                          1/1     Running   0             20d
pod/kube-proxy-6dt94                          1/1     Running   0             20d
pod/kube-proxy-cwwlh                          1/1     Running   0             20d
pod/kube-proxy-j5484                          1/1     Running   0             20d
pod/kube-proxy-zxb8n                          1/1     Running   0             20d
pod/kube-scheduler-k8s-master-1               1/1     Running   1 (20d ago)   20d
pod/kube-scheduler-k8s-master-2               1/1     Running   0             20d
pod/kube-scheduler-k8s-master-3               1/1     Running   0             20d

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns   ClusterIP   10.18.0.10   <none>        53/UDP,53/TCP,9153/TCP   20d

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/canal        5         5         5       5            5           kubernetes.io/os=linux   20d
daemonset.apps/kube-proxy   5         5         5       5            5           kubernetes.io/os=linux   20d

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/calico-kube-controllers   1/1     1            1           20d
deployment.apps/coredns                   2/2     2            2           20d

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/calico-kube-controllers-7c845d499   1         1         1       20d
replicaset.apps/coredns-64897985d                   2         2         2       20d

```
## Procedure Steps
### ./deploy.sh
#!/bin/bash
#Alpha
ansible-playbook -i hosts k-alpha.yml -e 'ansible_user=root ansible_password=root_password'

#Masters
ansible-playbook -i '192.168.29.232', -e 'host_name=k8s-master-2 p_value=254 ansible_user=root ansible_password=root_password' k-master.yml
ansible-playbook -i '192.168.29.233', -e 'host_name=k8s-master-3 p_value=253 ansible_user=root ansible_password=root_password' k-master.yml

#Slave
ansible-playbook -i '192.168.29.234', -e 'host_name=k8s-node-1 ansible_user=root ansible_password=root_password' k-slave.yml
ansible-playbook -i '192.168.29.235', -e 'host_name=k8s-node-2 ansible_user=root ansible_password=root_password' k-slave.yml

Above file contains needed environmental files and make sure you have changed the network interface name as ens33/ens192 in the vars/ directory for each files.
## Execution steps
Create another jump server with needed packages like kubectl, ansible and general packages. 
Simple 5 machine setup is ./deploy, thats it. It will slowly create machines configurations and installations as per this script.

Copy the file contents of kconf/admin.conf to ~/.kube/config and add the VIP to the hosts file with the hostname and the IP of the VIP as mentioned in config file.
## Result
A multimaster machine with 3 masters and 2 nodes are ready for your needs.

#### Things you need to do.
1. Add a storage class for PVCs, you can use the provider as you like.
Note: Will come with new section of SC with NFS backed with SSDs.
