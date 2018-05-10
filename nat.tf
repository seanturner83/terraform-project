resource "aws_eip" "nat" {
  count = "${length(var.availability_zones)}"
  vpc   = true

  tags {
    Name = "${var.vpc_name}_${element(var.availability_zones,count.index)}"
  }
}

resource "aws_nat_gateway" "main" {
  depends_on    = ["aws_internet_gateway.main"]
  count         = "${length(var.availability_zones)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${var.vpc_name}_${element(var.availability_zones,count.index)}"
  }
}
