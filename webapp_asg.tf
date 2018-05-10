data "template_file" "webapp" {
  template = "${file("${path.module}/templates/webapp_user_data.yaml")}"
}

resource "aws_security_group" "nodes" {
  name = "${var.vpc_name}_nodes"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "nodes_ingress_22" {
  type = "ingress"
  from_port = "22"
  to_port = "22"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id = "${aws_security_group.nodes.id}"
}

resource "aws_security_group_rule" "nodes_ingress_elb_http" {
  type = "ingress"
  from_port = "8080"
  to_port = "8080"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.elb_webapp.id}"
  security_group_id = "${aws_security_group.nodes.id}"
}

resource "aws_security_group_rule" "nodes_ingress_elb_https" {
  type = "ingress"
  from_port = "8443"
  to_port = "8443"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.elb_webapp.id}"
  security_group_id = "${aws_security_group.nodes.id}"
}

resource "aws_security_group_rule" "nodes_egress_all" {
  type = "egress"
  from_port = "0"
  to_port = "65535"
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.nodes.id}"
}

resource "aws_security_group" "elb_webapp" {
  name = "${var.vpc_name}_elb_webapp"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "elb_webapp_world_http" {
  type = "ingress"
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_webapp.id}"
}

resource "aws_security_group_rule" "elb_webapp_world_https" {
  type = "ingress"
  from_port = "443"
  to_port = "443"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_webapp.id}"
}

resource "aws_security_group_rule" "elb_webapp_egress_any_http" {
  type = "egress"
  from_port = "8080"
  to_port = "8080"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_webapp.id}"
}

resource "aws_security_group_rule" "elb_webapp_egress_any_https" {
  type = "egress"
  from_port = "8443"
  to_port = "8443"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb_webapp.id}"
}

resource "aws_launch_configuration" "webapp" {
  name_prefix = "webapp_"
  image_id = "${var.node_ami}"
  instance_type = "m5.large"
  user_data            = "${data.template_file.webapp.rendered}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.webapp.name}"
  security_groups = ["${aws_security_group.nodes.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

// this is an example showing some possible options for stickiness and http vs tcp load balancing
resource "aws_lb_cookie_stickiness_policy" "webapp-http" {
  name                     = "webapp-http"
  load_balancer            = "${aws_elb.webapp.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_elb" "webapp" {
  name = "webapp"
  subnets = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.elb_webapp.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 8443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    target = "HTTP:8080/"
    interval = 60
    timeout = 3
  }
}

resource "aws_autoscaling_group" "main" {
  name = "webapp"
  max_size = "${var.webapp_instance_count}"
  min_size = "${var.webapp_min_instances}"
  launch_configuration = "${aws_launch_configuration.webapp.name}"
  desired_capacity = "${var.webapp_desired_capacity}"
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]
  load_balancers = ["${aws_elb.webapp.name}"]

  tags {
    key = "Name"
    value = "${var.vpc_name}_webapp"
    propagate_at_launch = true
  }
}
