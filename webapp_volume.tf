resource "aws_ebs_volume" "main" {
  count = "${var.webapp_instance_count}"
  size = "${var.webapp_data_size}"
  availability_zone = "${element(var.availability_zones, count.index % length(var.availability_zones))}"
  type = "gp2"

  tags {
    Name = "${var.vpc_name}_webapp_${count.index+1}"
    Attach = "${var.vpc_name}_local_data"
  }

  lifecycle = {
    #prevent_destroy = true
  }
}
