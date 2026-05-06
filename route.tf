resource "aws_route_table" "bookvault_public_rt" {
  vpc_id = aws_vpc.bookvault.id

  tags = {
    Name = "bookvault-public-rt"
  }
}

resource "aws_route" "bookvault_public_route" {
  route_table_id         = aws_route_table.bookvault_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bookvault_igw.id
}

resource "aws_route_table_association" "bookvault_public_rt_assoc" {
  subnet_id      = aws_subnet.bookvault_public_subnet.id
  route_table_id = aws_route_table.bookvault_public_rt.id
}

resource "aws_route_table_association" "public_2" {
    subnet_id      = aws_subnet.bookvault_public_subnet_2.id
    route_table_id = aws_route_table.bookvault_public_rt.id
}


resource "aws_route_table" "bookvault_private_rt" {
  vpc_id = aws_vpc.bookvault.id

  tags = {
    Name = "bookvault-private-rt"
  }
}


resource "aws_route_table_association" "bookvault_private_rt_assoc" {
  subnet_id      = aws_subnet.bookvault_private_subnet.id
  route_table_id = aws_route_table.bookvault_private_rt.id
}

resource "aws_route_table_association" "bookvault_private_rt_assoc_2" {
  subnet_id      = aws_subnet.bookvault_private_subnet_2.id
  route_table_id = aws_route_table.bookvault_private_rt.id
}


resource "aws_eip" "nat_eip" {
    domain = "vpc"

    tags = {
        Name = "bookvault-nat-eip"
    }
}

resource "aws_nat_gateway" "bookvault_nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.bookvault_public_subnet.id

    depends_on = [aws_internet_gateway.bookvault_igw]

    tags = {
        Name = "bookvault-nat"
    }
}

resource "aws_route" "private_internet_access" {
    route_table_id         = aws_route_table.bookvault_private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.bookvault_nat.id
}