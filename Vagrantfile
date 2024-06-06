# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/focal64"
  
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.box_check_update = false
  config.vm.hostname = "ubuntu"
  config.vm.define "ubuntu-vm"

  config.vm.synced_folder ".", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "ubuntu"
    vb.cpus   = 2
    vb.memory = "4096"
  end

  config.vm.provision "shell", inline: <<-SHELL

    # uninstall old versions of docker
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; \
    do sudo apt-get remove $pkg; \
    done

    # 1 - Set up Docker's apt repository --------------------------------------------------------

    # i) Add Docker's official GPG key:
    sudo apt-get -y update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # ii) Add the repository to apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # 2 - Install the Docker packages -----------------------------------------------------------
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # start the docker service
    sudo systemctl start docker

    SHELL
end
