# Vagrantfile

Vagrant.configure("2") do |config|
   
    config.vm.box = "ubuntu/bionic64"
    config.vm.network "forwarded_port", guest: 9090, host: 9090

    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    end
     config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 1
      vb.name = "Prometheus-server"
    end
    config.vm.provision :shell, path: "run.sh"
  end