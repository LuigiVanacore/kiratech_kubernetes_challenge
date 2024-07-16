IMAGE_NAME = "bento/ubuntu-20.04"
NUMERO_NODI = 2

Vagrant.configure("2") do |config| 
    # configuro il timeout di boot perche' sul mio pc il tempo di avvio
    # e' molto alto
    config.vm.boot_timeout = 3000
    config.vbguest.auto_update = false
    config.disksize.size = '20GB' 


    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: "10.0.0.10"
	#faccio il port forwarding della porta per il frontend dell'app
        master.vm.network "forwarded_port", guest: 30080, host: 30080, auto_correct: true
        master.vm.hostname = "k8s-master"
        master.vm.provider "virtualbox" do |vb|
          vb.memory = 2048
          vb.cpus = 2
          #uso questo comando per assicurarmi di non avere problemi in fase di connessione ssh
          vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
        end
        master.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "./ansible/kubernetes-setup-playbook.yml"
            ansible.groups = {
                "k8s-master" => ["k8s-master"],
                "nodes" => ["node-[1:2]"]
                }
        end
    end

    (1..NUMERO_NODI).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "10.0.0.1#{i}"
            node.vm.hostname = "node-#{i}"
            node.vm.provider "virtualbox" do |vb|
                vb.memory = 1024
                vb.cpus = 1
                vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
            end
            node.vm.provision "ansible_local" do |ansible|
                ansible.playbook = "./ansible/kubernetes-setup-playbook.yml"
                ansible.groups = {
                    "k8s-master" => ["k8s-master"],
                    "nodes" => ["node-[1:2]"]
                    }
            end
        end
    end
end

