provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sca_key" {
  key_name   = "sca-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_private_key_file" {
  filename        = "${path.module}/sca-key.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0400"
}

resource "aws_vpc" "sca_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "sca-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.sca_vpc.id

  tags = { Name = "sca-igw" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.sca_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = { Name = "sca-public-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sca_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "sca-public-rt" }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  vpc_id      = aws_vpc.sca_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "dev-sg" }
}

resource "aws_security_group" "qa_sg" {
  name        = "qa-sg"
  vpc_id      = aws_vpc.sca_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "qa-sg" }
}

resource "aws_security_group" "prod_sg" {
  name        = "prod-sg"
  vpc_id      = aws_vpc.sca_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "prod-sg" }
}

resource "aws_instance" "dev" {
  ami                      = var.ubuntu_ami
  instance_type            = "t2.micro"
  key_name                 = aws_key_pair.sca_key.key_name
  subnet_id                = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  tags = { Name = "sca-dev", Env = "Dev" }
}

resource "aws_instance" "qa" {
  ami                      = var.ubuntu_ami
  instance_type            = "t2.micro"
  key_name                 = aws_key_pair.sca_key.key_name
  subnet_id                = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.qa_sg.id]

  tags = { Name = "sca-qa", Env = "QA" }
}

resource "aws_instance" "prod" {
  ami                      = var.ubuntu_ami
  instance_type            = "t2.micro"
  key_name                 = aws_key_pair.sca_key.key_name
  subnet_id                = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.prod_sg.id]

  tags = { Name = "sca-prod", Env = "Prod" }
}
