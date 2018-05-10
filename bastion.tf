resource "aws_security_group" "bastion" {
  name = "${var.vpc_name}_bastion"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "bastion_ingress_22" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type = "egress"
  from_port = "0"
  to_port = "65535"
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_instance" "bastion" {
  ami = "${var.bastion_ami}" 
  instance_type = "${var.bastion_instance_type}"
  subnet_id = "${aws_subnet.public.0.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "${var.vpc_name}_bastion"
  }
}
