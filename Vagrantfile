# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Source: https://github.com/julienlim/multinode-glusterfs-with-tendrl-vagrant
#

require 'yaml'

conf = YAML.load_file 'conf.yml'
ntp = conf['ntp_server']
storage_node_count = conf['storage_node_count']
bootstrap = conf['bootstrap']

# custom options based off bootstrap
# if you wrote a custom bootstrap script you will need to include it here
if bootstrap == 'bootstrap_upstream.sh'
  vm_box = 'centos/7'
elsif bootstrap == 'bootstrap_downstream.sh'
  vm_box = 'generic/rhel7'
  username = conf['rhel_username']
  password = conf['rhel_password']
  if !username.instance_of? String or !password.instance_of? String
    puts 'RHEL username and/or password configured incorrectly.'
    exit 1
  end
else
  puts 'No handler for this bootstrap. '\
       'Either the filename was improperly configured or a handler has yet to be written. '\
       'One can be added by modifying the Vagrantfile.'
  exit 1
end

Vagrant.configure(2) do |config|
  config.vm.box = vm_box
  config.ssh.forward_x11 = true
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 2
    vb.memory = 2048
  end

  # different customization required here based off OS
  if vm_box == 'centos/7'
    config.vm.provision :shell, :path => bootstrap, :args => [ntp]
  end

  if vm_box == 'generic/rhel7'
    config.vm.provision :shell, :path => bootstrap, :args => [ntp, username, password]
  end

  # Provision 4 VMs (node0..node3)
  (0..storage_node_count).each do |i|
    config.vm.define "node#{i}" do |hostconfig|
      hostconfig.vm.hostname = "node#{i}"
      hostconfig.vm.network "private_network", type: "dhcp"
      hostconfig.vm.provider "virtualbox" do |vb|
        unless File.exist?("node#{i}.vdi")
          vb.customize ['createhd', '--filename', "node#{i}", '--size', 1 * 1024]
        end

        # different customization required here based off OS
        if vm_box == 'centos/7'
          vb.customize ['storageattach', :id, '--storagectl', "IDE", '--port', "1", '--device', "1", '--type', 'hdd', '--medium', "node#{i}.vdi"]
        end

        if vm_box == 'generic/rhel7'
          vb.customize ['storageattach', :id, '--storagectl', "IDE Controller", '--port', "1", '--device', "1", '--type', 'hdd', '--medium', "node#{i}.vdi"]
        end

        vb.name = "node#{i}"
      end

      if i == storage_node_count
        hostconfig.vm.provision :ansible do |ansible|
          ansible.limit = 'all'
          ansible.playbook = "network.yml"
        end

        hostconfig.vm.provision :ansible do |ansible|
          ansible.limit = 'all'
          ansible.groups = {
            'gluster_servers' => ["node[1:#{storage_node_count}]"],
          }
          ansible.playbook = 'filesystem.yml'
        end

        volume_string = "gluster volume create vol1 "
        for j in 1..storage_node_count do
          volume_string << "node#{j}:/bricks/brick1 "
        end
        volume_string << "force"

        hostconfig.vm.provision :ansible do |ansible|
          ansible.limit = 'all'
          ansible.groups = {
            'node1' => ["node1"],
            'other_storage_nodes' => ["node[2:#{storage_node_count}]"]
          }
          ansible.extra_vars = {
            "volume_string": volume_string
          }
          ansible.playbook = 'cluster.yml'
        end
      end

    end
  end
end
