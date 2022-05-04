#!/bin/bash
#Alpha
ansible-playbook -i hosts k-alpha.yml -e 'ansible_user=root ansible_password=PrIsa221S476e#'

#Masters
ansible-playbook -i '172.30.17.62', -e 'host_name=k8s-master-2 p_value=254 ansible_user=root ansible_password=PrIsa221S476e#' k-master.yml
ansible-playbook -i '172.30.17.63', -e 'host_name=k8s-master-3 p_value=253 ansible_user=root ansible_password=PrIsa221S476e#' k-master.yml

#Slave
ansible-playbook -i '172.30.17.64', -e 'host_name=k8s-node-1 ansible_user=root ansible_password=PrIsa221S476e#' k-slave.yml
ansible-playbook -i '172.30.17.65', -e 'host_name=k8s-node-2 ansible_user=root ansible_password=PrIsa221S476e#' k-slave.yml
