provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "golunch_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "golunch-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.golunch_vpc.id

  tags = {
    Name = "golunch-igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.golunch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "golunch-public-rt"
  }
}

# Subnets públicas
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.golunch_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.golunch_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b"][count.index]

  tags = {
    Name = "golunch-public-${count.index}"
  }
}

# Associação das subnets à route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet[*].id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group liberando PostgreSQL para qualquer IP (pode restringir para seu IP público depois)
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.golunch_vpc.id
  name   = "golunch-db-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "golunch-db-sg"
  }
}

# Subnet Group para o RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "golunch-db-subnet-group"
  subnet_ids = aws_subnet.public_subnet[*].id

  tags = {
    Name = "golunch-db-subnet-group"
  }
}

# Instância RDS PostgreSQL
resource "aws_db_instance" "golunch_postgres" {
  identifier             = "golunch-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "golunchDB"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true
}

# Output da URL de conexão
output "database_url" {
  value = aws_db_instance.golunch_postgres.address
}
