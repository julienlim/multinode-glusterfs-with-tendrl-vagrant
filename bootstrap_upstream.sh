#!/bin/bash -ux

### install pre-requisites
sudo yum install nano -y
sudo yum install git -y
sudo yum install wget -y
sudo yum install python-dns -y
sudo yum install ntpdate -y
sudo ntpdate $1

### install ansible
sudo yum install epel-release -y
sudo yum install ansible -y

### configure disk
# fdisk /dev/sdb
# mkfs.xfs /dev/sdb1
# parted /dev/sdb print

### specify where bricks to be mounted
mkdir /bricks
mkdir /bricks/brick1
echo "#/dev/sdb1 	/bricks/brick1				xfs defaults 0 0" >> /etc/fstab
# mount /bricks/brick1  OR mount -a

### install some extra utilities on node0 (Tendrl master) and Gluster on Tendrl nodes
if [ $HOSTNAME == 'node0' ] 
then
  yum install epel-release yum-plugin-copr -y
  yum copr enable tendrl/release -y
  # clone tendrl-ansible
  #cd /opt
  #git clone https://github.com/Tendrl/tendrl-ansible.git
  yum install tendrl-ansible -y
  
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
  # install gluster 3.12.1 and gstatus on storage nodes
  sudo yum install centos-release-gluster -y
  sudo yum install glusterfs-server -y

  sudo systemctl enable glusterd
  sudo systemctl start glusterd
  sudo systemctl status glusterd

  cd /opt
  git clone https://github.com/gluster/gstatus
  cd /opt/gstatus
  python setup.py install
fi

service firewalld stop
systemctl disable firewalld
iptables --flush

# done

