# OpenStack example
data "openstack_networking_network_v2" "private_net" {
  count = var.cloud_provider == "openstack" ? 1 : 0
  name  = var.private_network
}

data "openstack_networking_network_v2" "external_net" {
  count = var.cloud_provider == "openstack" ? 1 : 0
  name  = var.external_network
}

