resource "aws_subnet" "private-subnet" {
  count             = var.subnet_count_private
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_cidrs_private, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "${var.prefix_subnet_name_private}-${count.index + 1}"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = var.nat_gw_name
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  #subnet_id     = aws_subnet.private-subnet[0].id
  subnet_id = var.public_subnet_id

  tags = {
    Name = "${var.nat_gw_name}-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "this" {
  count          = var.subnet_count_private
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}