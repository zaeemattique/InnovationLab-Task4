resource "aws_vpc" "Task4-vpc-zaeem" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Task4-vpc-zaeem"
  }
}

resource "aws_subnet" "Task4-publicSNA-zaeem" {
  vpc_id            = aws_vpc.Task4-vpc-zaeem.id
  cidr_block        = var.subnet_cidr_A
  availability_zone = "us-west-2a"

    tags = {
        Name = "Task4-publicSN-zaeem"
    }
}

resource "aws_subnet" "Task4-publicSNB-zaeem" {
  vpc_id            = aws_vpc.Task4-vpc-zaeem.id
  cidr_block        = var.subnet_cidr_B
  availability_zone = "us-west-2b"

    tags = {
        Name = "Task4-publicSN-zaeem"
    }
}

resource "aws_internet_gateway" "Task4-igw-zaeem" {
  vpc_id = aws_vpc.Task4-vpc-zaeem.id  

    tags = {
        Name = "Task4-igw-zaeem"
    }
}

resource "aws_route_table" "Task4-publicRT-zaeem" {
  vpc_id = aws_vpc.Task4-vpc-zaeem.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Task4-igw-zaeem.id
  }

  tags = {
    Name = "Task4-publicRT-zaeem"
  }
}

resource "aws_route_table_association" "Task4-publicRTA-A-zaeem" {
  subnet_id      = aws_subnet.Task4-publicSNA-zaeem.id
  route_table_id = aws_route_table.Task4-publicRT-zaeem.id
}

resource "aws_route_table_association" "Task4-publicRTA-B-zaeem" {
  subnet_id = aws_subnet.Task4-publicSNB-zaeem.id
  route_table_id = aws_route_table.Task4-publicRT-zaeem.id
}
