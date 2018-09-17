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
