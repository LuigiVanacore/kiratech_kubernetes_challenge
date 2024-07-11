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
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
      "echo 'overlay\nbr_netfilter' | sudo tee /etc/modules-load.d/containerd.conf",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "echo 'net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/kubernetes.conf",
      "sudo sysctl --system",
      "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt update",
      "sudo apt install -y containerd.io",
      "containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "sudo systemctl enable containerd",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl"
    ]
  }
}

resource "null_resource" "install_k8s_worker1" {
  depends_on = [null_resource.install_k8s_master]

  connection {
    type        = "ssh"
    host        = var.worker1_ip
    user        = "vagrant"
    private_key = file("../servers/.vagrant/machines/worker1/virtualbox/private_key")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
      "sudo sed -i \"/#\\$nrconf{restart} = 'i';/s/.*/\\$nrconf{restart} = 'a';/\" /etc/needrestart/needrestart.conf",
      "echo 'overlay\nbr_netfilter' | sudo tee /etc/modules-load.d/containerd.conf",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "echo 'net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/kubernetes.conf",
      "sudo sysctl --system",
      "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt update",
      "sudo apt install -y containerd.io",
      "containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "sudo systemctl enable containerd",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl"
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
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",
      "echo 'overlay\nbr_netfilter' | sudo tee /etc/modules-load.d/containerd.conf",
      "sudo modprobe overlay",
      "sudo modprobe br_netfilter",
      "echo 'net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/kubernetes.conf",
      "sudo sysctl --system",
      "sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt update",
      "sudo apt install -y containerd.io",
      "containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml",
      "sudo systemctl restart containerd",
      "sudo systemctl enable containerd",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl"
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
