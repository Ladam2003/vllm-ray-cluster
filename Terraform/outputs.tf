output "bastion_info" {
  value = {
    name = openstack_compute_instance_v2.bastion[0].name
    ip   = openstack_compute_instance_v2.bastion[0].access_ip_v4
  }
}

output "worker_info" {
  value = [
    for w in openstack_compute_instance_v2.worker : {
      name = w.name
      ip   = w.access_ip_v4
    }
  ]
}
