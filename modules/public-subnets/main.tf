resource "aws_subnet" "public-subnet" {
  count             = var.subnet_count_public
  vpc_id            = var.vpc_id
  cidr_block        = element(var.subnet_cidrs_public, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "${var.prefix_subnet_name_public}-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.internet_gw
  }
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  count          = var.subnet_count_public
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.this.id
}