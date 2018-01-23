# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Source: https://github.com/julienlim/multinode-glusterfs-with-tendrl-vagrant
#

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.ssh.forward_x11 = true
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 2
    vb.memory = 2048
  end

  config.vm.provision "shell", path: "bootstrap.sh"

  # Provision 4 VMs (node0..node3)
  (0..3).each do |i|
    config.vm.define "node#{i}" do |hostconfig|
      hostconfig.vm.hostname = "node#{i}"
      hostconfig.vm.network "private_network", type: "dhcp"
      hostconfig.vm.provider "virtualbox" do |vb|
        unless File.exist?("node#{i}.vdi")
          vb.customize ['createhd', '--filename', "node#{i}", '--size', 1 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', "IDE", '--port', "1", '--device', "1", '--type', 'hdd', '--medium', "node#{i}.vdi"]
        vb.name = "node#{i}"
      end
    end
  end
end

