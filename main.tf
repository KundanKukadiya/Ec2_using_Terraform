resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}

resource "aws_subnet" "main-subnet" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "main-Gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "dev-Gw"
  }
}

resource "aws_route_table" "main-route" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "Dev-Route"
  }
}

resource "aws_route" "default-route" {
  route_table_id         = aws_route_table.main-route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-Gw.id

}

resource "aws_route_table_association" "main-assoc" {
  subnet_id      = aws_subnet.main-subnet.id
  route_table_id = aws_route_table.main-route.id

}

resource "aws_security_group" "main-sg" {
  name        = "Dev-sg"
  description = "Dev security group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "main-key" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

resource "aws_instance" "main-ec2" {
  instance_type   = "t2.micro"
  ami             = "ami-06d4b7182ac3480fa"
  key_name        = aws_key_pair.main-key.id
  security_groups = [aws_security_group.main-sg.id]
  subnet_id       = aws_subnet.main-subnet.id

  tags = {
    Name = "main-ec2"
  }

  root_block_device {
    volume_size = 8
  }
}