#!/bin/bash -ux

# subscription-manager credentials
subscription-manager register --username $2 --password $3 --auto-attach
subscription-manager repos --disable=rhel-7-server-htb-rpms

# install pre-requisites
sudo yum install nano -y
sudo yum install ntpdate -y
sudo ntpdate $1

# prep for mounting later
mkdir /bricks
mkdir /bricks/brick1
echo "/dev/sdb1 	/bricks/brick1				xfs defaults 0 0" >> /etc/fstab

# enable repos needed for all nodes
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-7-server-ansible-2-rpms

if [ $HOSTNAME == 'node0' ] 
# Server Node
then
    cd /etc/yum.repos.d

    # enable repos specified by RHGS Quick Start Guide
    subscription-manager repos --enable=rhel-7-server-extras-rpms
    subscription-manager repos --enable=rh-gluster-3-web-admin-server-for-rhel-7-server-rpms

    # remove epel.repo and epel-testing.repo
    rm -f epel.repo
    rm -f epel-testing.repo
    yum clean all

    # install tendrl-ansible
    yum -y install ansible tendrl-ansible

    # create inventory file for tendrl-ansible
    cd /usr/share/doc/tendrl-ansible-*

    cat > ./inventory <<EOL

[gluster_servers]
node1
node2
node3
[tendrl_server]
node0
[all:vars]

# Mandatory variables. In this example, 192.0.2.1 is ip address of tendrl
# server, tendrl.example.com is a hostname of tendrl server and
# tendrl.example.com hostname is translated to 192.0.2.1 ip address.
etcd_ip_address=172.28.128.3
etcd_fqdn=172.28.128.3
graphite_fqdn=172.28.128.3
configure_firewalld_for_tendrl=false

# when direct ssh login of root user is not allowed and you are connecting via
# non-root cloud-user account, which can leverage sudo to run any command as
# root without any password
#ansible_become=yes
#ansible_user=cloud-user

EOL

# Storage Nodes
else
    cd /etc/yum.repos.d

    # enable repos specified by RHGS Quick Start Guide
    subscription-manager repos --enable=rh-gluster-3-for-rhel-7-server-rpms
    subscription-manager repos --enable=rh-gluster-3-web-admin-agent-for-rhel-7-server-rpms

    # remove epel.repo and epel-testing.repo
    rm -f epel.repo
    rm -f epel-testing.repo
    yum clean all

    # gluster install
    yum install redhat-storage-server -y

    # start gluster service
    sudo systemctl enable glusterd
    sudo systemctl start glusterd
    sudo systemctl status glusterd

fi

service firewalld stop
systemctl disable firewalld
iptables --flush

# done
