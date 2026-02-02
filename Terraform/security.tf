resource "openstack_networking_secgroup_v2" "secgroup" {
  count       = var.cloud_provider == "openstack" ? 1 : 0
  name        = "${var.project_prefix}-secgroup-${var.user_name}"
  description = "Base security group"
}

# ICMP / TCP / UDP belső
resource "openstack_networking_secgroup_rule_v2" "internal_rules" {
  count             = var.cloud_provider == "openstack" ? 3 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id

  protocol = lookup({0="icmp", 1="tcp", 2="udp"}, count.index)
  port_range_min = count.index == 0 ? null : 1
  port_range_max = count.index == 0 ? null : 65535
}

# Publikus portok
resource "openstack_networking_secgroup_rule_v2" "public_ports" {
  count             = var.cloud_provider == "openstack" ? length(var.allowed_ports) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.allowed_ports[count.index]
  port_range_max    = var.allowed_ports[count.index]
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
