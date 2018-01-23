#!/bin/bash -ux

### install pre-requisites
sudo yum install git -y
sudo yum install wget -y
sudo yum install python-dns -y
sudo yum install ntpdate -y
sudo ntpdate <your_NTP_server>

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

