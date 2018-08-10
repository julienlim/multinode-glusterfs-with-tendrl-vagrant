# multinode-glusterfs-with-tendrl-vagrant
Multinode Glusterfs with All-in-1 Tendrl for Monitoring Vagrant 

This provides instructions for how to setup a Vagrant environment with 4 VM's, i.e. a 3-node Gluster trusted storage pool (with Tendrl agents) and another node serving as the Tendrl server.  

Important Note: This is for demo purposes, as I used a much smaller hardware footprint than what is specified in the [Tendrl Release v1.5.4 Install Guide](https://github.com/Tendrl/documentation/wiki/Tendrl-release-v1.5.4-(install-guide)).

My Test / Demo setup:

``` Physical host
Physical Host HW: (1) 3.1 GHz Intel Core i7 (4 cores), 16 GB RAM, ~1 TB of disk space
```

Vagrant/Virtual Box setup:

``` VM setup
4 VMs (node0..node3) - 3 node Gluster trusted storage pool, and 1 node Tendrl server on a private network (virtual)
      
Each node is configured with the following: 2 vCPU, 2 GB RAM, Boot Disk 40 GB, additional virtualHD 1 GB
   node0 - Tendrl server (all-in-1), so etcd and graphite are co-located on node0
   node1..node3 - Gluster nodes
```

Setting up the Vagrant Boxes:

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

2. Download and install [Vagrant](http://www.vagrantup.com/downloads.html).

3. Download and install [Ansible](https://github.com/ansible/ansible).

4. Create a directory to put the scripts in, e.g. “mydir”.  Download [Vagrantfile](https://github.com/julienlim/multinode-glusterfs-with-tendrl-vagrant/blob/master/Vagrantfile) and [bootstrap.sh](https://github.com/julienlim/multinode-glusterfs-with-tendrl-vagrant/blob/master/bootstrap.sh) to “mydir” directory.

5. Modify Vagrantfile if you want more than 4 nodes (VMs), e.g. node0 will be the Tendrl master, and node1..node3 are the Gluster trusted pool and Tendrl nodes (agents).  Note: a virtual hard drive will be created/allocated on each of the nodes for 1 GB capacity.

6. Modify bootstrap.sh for anything you want installed or configured on each of the nodes including adding the NTP server.

7. Create the vagrant boxes:
``` run on physical host
$ vagrant up
```

8. If “vagrant up” ran successfully, you would now see node0..node3 running. Ansible should have also taken over and handled the rest of the setup procedure.

9. You’re now ready to deploy Tendrl using tendrl-ansible.  
        Go to [Tendrl Releases](https://github.com/Tendrl/documentation/wiki/Tendrl-Releases) to find the latest Tendrl release installation instructions, e.g. [tendrl-ansible-1.5.4](/usr/share/doc/tendrl-ansible-1.5.4/README.md).

10. When you're all done, tell Vagrant to destroy the VMs.

```run on physical host
### Cleanup
$ vagrant destroy -f
```

If you don't wish to destroy the VMs but only remove tendrl, follow the [tendrl-cleanup](https://github.com/shtripat/tendrl-cleanup) provided at https://github.com/shtripat/tendrl-cleanup.


# About the Author
This project was created by Ju-Lien Lim as an example for how to setup a demo environment for Tendrl to monitor Glusterfs.

Additional ansible automation was added by [Nathan Weinberg](https://github.com/nathan-weinberg) partially using assets from [tendrl-vagrant](https://github.com/Tendrl/tendrl-vagrant).
