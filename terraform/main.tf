provider "local" {
  host = "localhost"
}

variable "master_ip" {
  description = "IP address of the master node"
  default     = "10.0.0.10"
}

variable "worker1_ip" {
  description = "IP address of the worker1 node"
  default     = "10.0.0.11"
}

variable "worker2_ip" {
  description = "IP address of the worker2 node"
  default     = "10.0.0.12"
}

resource "null_resource" "install_k8s_master" {
  connection {
    type        = "ssh"
    host        = var.master_ip
    user        = "vagrant"
    private_key = file("../servers/.vagrant/machines/master/virtualbox/private_key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y apt-transport-https curl",
       "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
        "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt update",
        "sudo apt -y install vim git wget",
        "sudo snap install kubectl --classic",
        "sudo snap install kubeadm --classic",
        "sudo snap install kubelet --classic",
        "sudo apt-mark hold kubelet kubeadm kubectl",

      "curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.20.0/crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo tar -C /usr/local/bin -xzf crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",
      "sudo kubeadm init --apiserver-advertise-address=${var.master_ip} --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
    ]
  }
}

resource "null_resource" "install_k8s_worker1" {
  depends_on = [null_resource.install_k8s_master]

  connection {
    type        = "ssh"
    host        = var.worker1_ip
    user        = "vagrant"
    private_key = file("../servers/.vagrant/machines/worker2/virtualbox/private_key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y apt-transport-https curl",
      "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
        "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt update",
        "sudo apt -y install vim git wget",
        "sudo snap install kubectl --classic",
        "sudo snap install kubeadm --classic",
        "sudo snap install kubelet --classic",
        "sudo apt-mark hold kubelet kubeadm kubectl",
      "curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.20.0/crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo tar -C /usr/local/bin -xzf crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",
      "JOIN_COMMAND=$(ssh vagrant@${var.master_ip} sudo kubeadm token create --print-join-command)",
      "sudo $JOIN_COMMAND"
    ]
  }
}

resource "null_resource" "install_k8s_worker2" {
  depends_on = [null_resource.install_k8s_master]

  connection {
    type        = "ssh"
    host        = var.worker2_ip
    user        = "vagrant"
    private_key = file("../servers/.vagrant/machines/worker2/virtualbox/private_key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install -y apt-transport-https curl",
      "sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
        "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
        "sudo apt update",
        "sudo apt -y install vim git wget",
        "sudo snap install kubectl --classic",
        "sudo snap install kubeadm --classic",
        "sudo snap install kubelet --classic",
        "sudo apt-mark hold kubelet kubeadm kubectl",
      "curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.20.0/crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo tar -C /usr/local/bin -xzf crictl-v1.20.0-linux-amd64.tar.gz",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",
      "JOIN_COMMAND=$(ssh vagrant@${var.master_ip} sudo kubeadm token create --print-join-command)",
      "sudo $JOIN_COMMAND"
    ]
  }
}

output "master_ip" {
  value = var.master_ip
}

output "worker1_ip" {
  value = var.worker1_ip
}

output "worker2_ip" {
  value = var.worker2_ip
}

