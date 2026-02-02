locals {
  workers = [
    for i, vm in openstack_compute_instance_v2.worker : {
      name = vm.name
      ip   = vm.access_ip_v4
    }
  ]
}

resource "local_file" "ssh_config" {
  filename = pathexpand("~/.ssh/config")

  content = <<-EOT
# === Managed by Terraform ===

Host bastion_host
  HostName ${openstack_compute_instance_v2.bastion[0].access_ip_v4}
  User ubuntu
  ForwardAgent yes
  IdentityFile ~/.ssh/id_rsa

%{ for w in local.workers ~}
Host ${w.name}
  HostName ${w.ip}
  User ubuntu
  ProxyJump bastion_host
  ForwardAgent yes
  IdentityFile ~/.ssh/id_rsa
%{ endfor ~}

# === End Managed by Terraform ===
EOT
}
