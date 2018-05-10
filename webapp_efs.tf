resource "aws_efs_file_system" "webapp" {
  creation_token = "webapp"

  tags {
    Name = "webapp-shared-storage"
  }
}

resource "aws_efs_mount_target" "webapp" {
  file_system_id = "${aws_efs_file_system.webapp.id}"
  count = "${length(var.availability_zones)}"
  subnet_id = "${element("${aws_subnet.private.*.id}", count.index)}"
  security_groups = ["${aws_security_group.webapp_efs.id}"]
}

resource "aws_security_group" "webapp_efs" {
  name = "${var.vpc_name}_webapp_efs"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "efs_ingress_nodes_nfs4" {
  type = "ingress"
  from_port = "2049"
  to_port = "2049"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.nodes.id}"
  security_group_id = "${aws_security_group.webapp_efs.id}"
}
