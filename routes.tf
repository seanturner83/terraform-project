resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.vpc_name}_public"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "private" {
  count  = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.vpc_name}_private_${var.availability_zones[count.index]}"
  }
}

resource "aws_route" "private" {
  count                  = "${length(var.availability_zones)}"
  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.main.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.availability_zones)}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}
