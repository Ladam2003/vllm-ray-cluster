data "openstack_images_image_v2" "vm_image" {
  count = var.cloud_provider == "openstack" ? 1 : 0
  name  = var.image_name
}

resource "openstack_compute_instance_v2" "bastion" {
  count         = var.cloud_provider == "openstack" ? 1 : 0
  name          = "${var.project_prefix}-bastion-${var.user_name}"
  flavor_name   = var.flavor_name
  key_pair      = var.keypair_name
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  block_device {
    uuid                  = data.openstack_images_image_v2.vm_image[0].id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.volume_size
    delete_on_termination = true
    boot_index            = 0
  }

  network {
    name = var.private_network
  }
}

resource "openstack_compute_instance_v2" "worker" {
  count         = var.cloud_provider == "openstack" ? var.worker_count : 0
  name          = "${var.project_prefix}-worker-${var.user_name}-${count.index + 1}"
  flavor_name   = var.flavor_name
  key_pair      = var.keypair_name
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  block_device {
    uuid                  = data.openstack_images_image_v2.vm_image[0].id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.volume_size
    delete_on_termination = true
    boot_index            = 0
  }

  network {
    name = var.private_network
  }
}
