locals {
  workers = [
    for i, vm in openstack_compute_instance_v2.worker : {
      name = vm.name
      ip   = vm.access_ip_v4
    }
  ]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOT
[bastion]
bastion_host ansible_host=${openstack_compute_instance_v2.bastion[0].access_ip_v4} ansible_user=ubuntu

[workers]
%{ for w in local.workers ~}
${w.name} ansible_host=${w.ip} ansible_user=ubuntu
%{ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_ssh_common_args='-o ForwardAgent=yes -o ProxyJump=bastion_host'
EOT
}
