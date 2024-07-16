terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.29"
    }
  }

  required_version = ">= 1.0.0"
}

provider "local" {}

provider "kubernetes" {
  config_path = "../kubeconfig/admin.conf"
}

variable "master_ip" {
  description = "IP address of the master node"
  type        = string
  default     = "10.0.0.10"
}

variable "ssh_user" {
  description = "SSH user for the master node"
  type        = string
  default     = "vagrant"
}


variable "master_private_key" {
  description = "Path to the private key for SSH access to the master node"
  type        = string
  default     = "../.vagrant/machines/k8s-master/virtualbox/private_key"
}

resource "null_resource" "check_nodes_and_download_yaml" {
  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml",
      "while true; do",
      "  if kubectl get nodes | grep -E 'NotReady|Unknown'; then",
      "    echo 'Some nodes are not ready yet. Waiting...';",
      "    sleep 5;",
      "  else",
      "    echo 'All nodes are ready.';",
      "    break;",
      "  fi",
      "done",
      "curl -o /home/vagrant/kube-bench-job.yaml https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml"
    ]

    connection {
      type        = "ssh"
      host        = var.master_ip
      user        = var.ssh_user
      private_key = file(var.master_private_key)
    }
  }
}

resource "null_resource" "apply_kube_bench" {
  depends_on = [null_resource.check_nodes_and_download_yaml]

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f /home/vagrant/kube-bench-job.yaml"
    ]

    connection {
      type        = "ssh"
      host        = var.master_ip
      user        = var.ssh_user
      private_key = file(var.master_private_key)
    }
  }
}

resource "kubernetes_namespace" "kiratech_test" {
  depends_on = [null_resource.check_nodes_and_download_yaml]
  metadata {
    name = "kiratech-test"
  }
}


resource "null_resource" "install_helm_and_deploy_app" {
  depends_on = [kubernetes_namespace.kiratech_test]
  provisioner "remote-exec" {
    inline = [
      "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null",
      "sudo apt-get install apt-transport-https --yes",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main\" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list",
      "sudo apt-get update",
      "sudo apt-get install helm --yes",
      "helm install myapp /vagrant/helm/"
    ]

    connection {
      type        = "ssh"
      host        = var.master_ip
      user        = var.ssh_user
      private_key = file(var.master_private_key)
    }
  }
}

