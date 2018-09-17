# Multinode Glusterfs with All-in-1 Tendrl/WA for Monitoring Vagrant 

Basic Information:
* Setup uses VirtualBox to create 4 Virtual Machines, each of which act as a host/node.
* Setup of the nodes is done using Vagrant and Ansible. 
* This setup is intended to be used by Red Hat employees to quickly be able to get one 3-node cluster up and running with Gluster and our Web Administration tool. This allows for a fast build of an environment that is easy to test on. 
* If you desire more than 3 Storage Nodes, more than 3 bricks, more memory on each VM, etc, then you will need to alter the files yourself. 

Basic Requirements: 
* More than 4 CPU cores (1 is needed for all 4 VM's)
* 8GB of free memory (2GB for all 4 VM's)
* Alterations of the number of cores for each node and the memory for each can be done in the "Vagrantfile". 
* Laptop specs that this is confirmed to work with are a Intel® Core™ i7-4810MQ CPU @ 2.80GHz × 8 processor and 15.3GiB of memory. 
* Works on RHEL and Fedora systems.

Vagrant/Virtual Box Setup:
* 4 VMs (node0..node3) - 3 node Gluster trusted storage pool, and 1 node Tendrl server on a private network (virtual)
* Each node is configured with the following: 2 vCPU, 2 GB RAM, Boot Disk 40 GB, additional virtualHD 1 GB
   * node0 - Tendrl server (all-in-1), so etcd and graphite are co-located on node0
   * node1..node3 - Gluster nodes

Bootstrap Options:
* bootstrap_upstream.sh - creates CentOS VMs and installs upstream (Gluster and Tendrl)
* bootstrap_downstream.sh - creates RHEL7 VMs and installs downstream (RHGS and WA)

Ensure both these bootstrap_upstream.sh and bootstrap_downstream.sh files have executable permissions.
```
chmod 755 bootstrap_*.sh
```

Use this README to quickly create and set up a 4-Node setup. The 4 nodes consist of one server node and 3 storage nodes that each include 1 brick. The only tools you should need are the three installs in Step 1 and the repo contents. Note that a downstream setup does require a Red Hat Subscription.

## Initial Setup

### Setup Basic Software Requirements
Install [Ansible](https://github.com/ansible/ansible), [VirtualBox](https://www.virtualbox.org/wiki/Downloads), and [Vagrant](http://www.vagrantup.com/downloads.html).

You may have to run the command `$ sudo yum install kernel-devel dkms kernel-headers` (without this some necessary dependecies might fail) 

### Setup Configuration of Virtual Machines
Create a file called "conf.yml" based off "conf.yml.sample" with the required relevant data, i.e. your Red Hat credentials, desired NTP server, the bootstrap file you wish you use, or if you want more than 4 nodes (VMs), e.g. node0 will be the Tendrl master, and node1..node(n) are the Gluster trusted pool and Tendrl nodes (agents). Note: a virtual hard drive will be created/allocated on each of the nodes for 1 GB capacity.

### Run Vagrant Up to Setup Virtual Machines
Within the WA directory, run `$ vagrant up --provider virtualbox`.

If an error occurs with a failure in enabling gluster and connecting to a peer to make a peer probe, then there was likely a network error when attempting to download certain repos. The best action when this happens is to `$ vagrant destroy -f` and then `$ vagrant up` again.

After this is completed, you should have 4 VMs (node0...node3) up and running. Ansible should have also taken over and handled the rest of the setup procedure.

At this point should be able to passwordless SSH between all nodes, and your gluster cluster should be up and running.

### Pre-Install Configuration of WA
Run `vagrant ssh node0` then `$ sudo -i` to go into the root user of node0, then run `$ cd /usr/share/doc/tendrl-ansible-VERSION` such that VERSION is your version of tendrl-ansible (Current version is 1.6.3).

Then create a new file "inventory_file" by copying the contents from the Inventory Example at the bottom of this README (IP address may vary, but should be the inet ip for node0). Additional information on the inventory_file can be found in the [tendrl-ansible](https://github.com/Tendrl/tendrl-ansible) documentation.

### Install WA
Run `$ ansible-playbook -i inventory_file site.yml`. If you run into issues try running `$ ansible -i inventory_file -m ping all` and ensure all nodes are able to communicate with one another.

You should now be able to access the Tendrl dashboard from your machine via a browser at this URL: `http://<node0-ip-address>/`

By default, the username for WA is admin, and the password is adminuser.

## About the Author
This project was created by Ju-Lien Lim as an example for how to setup a demo environment for Tendrl to monitor Glusterfs.

Additional ansible automation and bootstrap options was added by [Nathan Weinberg](https://github.com/nathan-weinberg) partially using assets from [tendrl-vagrant](https://github.com/Tendrl/tendrl-vagrant).

README was written largely by [Mike Lanotte](https://github.com/mlanotte1998), with additional changes made by Nathan Weinberg.

## Inventory File Example 

```
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
```
