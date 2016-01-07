# -*- mode: ruby -*-
# vi: set ft=ruby :

# Browed from https://gitlab.com/theerasmas/nixos-vagrant-quickstart
Vagrant.configure("2") do |config|
    project = "jbx" 
    # our custom built VM
    config.vm.box = "jimmyyen/nixos-15.09-x86_64"

    config.vm.provider "virtualbox" do |vb|
        # Use VBoxManage to customize the VM. For example to change memory:
        vb.customize ["modifyvm", :id, "--memory", "2048"]
    end


    # creates a uniquely named virtualbox instance using the value of `project`
    config.vm.define project do |v|
        nil
    end
    config.vm.provision :nixos, :path => "configuration.nix"
end
