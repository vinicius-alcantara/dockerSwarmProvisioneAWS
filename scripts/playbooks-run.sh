#!/bin/bash
ANSIBLE_FORCE_COLOR=true
sleep 120 
cat $(pwd)'/ansible-playbooks/hosts-template' > $(pwd)'/ansible-playbooks/hosts'
sed -i s/public_ip_bastion/$EXTERNAL_IP_BASTION/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_manager_1/$INTERNAL_IP_NODE_MANAGER_1/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_manager_2/$INTERNAL_IP_NODE_MANAGER_2/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_manager_3/$INTERNAL_IP_NODE_MANAGER_3/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_worker_1/$INTERNAL_IP_NODE_WORKER_1/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_worker_2/$INTERNAL_IP_NODE_WORKER_2/g $(pwd)'/ansible-playbooks/hosts' &&
sed -i s/private_ip_worker_3/$INTERNAL_IP_NODE_WORKER_3/g $(pwd)'/ansible-playbooks/hosts' &&
ansible-playbook -i $(pwd)'/ansible-playbooks/hosts' $(pwd)'/ansible-playbooks/mountDiskData/playbookMountDiskData.yml' &&
ansible-playbook -i $(pwd)'/ansible-playbooks/hosts' $(pwd)'/ansible-playbooks/installDocker/playbookInstallDocker.yml' &&
ansible-playbook -i $(pwd)'/ansible-playbooks/hosts' $(pwd)'/ansible-playbooks/configureSwarmCluster/playbookConfigureSwarmCluster.yml' \
--extra-vars private_ip_manager_1=$INTERNAL_IP_NODE_MANAGER_1 \
--extra-vars private_ip_manager_2=$INTERNAL_IP_NODE_MANAGER_2 \
--extra-vars private_ip_manager_3=$INTERNAL_IP_NODE_MANAGER_3 \
--extra-vars private_ip_worker_1=$INTERNAL_IP_NODE_WORKER_1 \
--extra-vars private_ip_worker_2=$INTERNAL_IP_NODE_WORKER_2 \
--extra-vars private_ip_worker_3=$INTERNAL_IP_NODE_WORKER_3 #&&
# ansible-playbook -i $(pwd)'/ansible-playbooks/hosts' $(pwd)'/ansible-playbooks/installZabbixAgent/playbookInstallZabbixAgentLinux.yml'