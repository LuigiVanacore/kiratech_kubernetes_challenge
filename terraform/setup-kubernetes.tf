provider "local" {}

provider "kubernetes" {
  config_path    = "../servers2/kubeconfig/admin.conf"
}

variable "master_ip" {
  description = "IP address of the master node"
  default     = "10.0.0.10"
}

variable "ssh_user" {
  description = "IP address of the master node"
  default     = "vagrant"
}

variable "kubernetes_config_path" {
  description = ""
  default     = "../servers/kubeconfig/kubeconfig"
}



variable "calico_url" {
  description = "URL to download the Calico YAML"
  default     = "https://docs.projectcalico.org/v3.20/manifests/calico.yaml"
}

variable "master_private_key" {
    description = ""
    default = "../servers2/.vagrant/machines/k8s-master/virtualbox/private_key"
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

