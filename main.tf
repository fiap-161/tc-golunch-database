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

# Instância RDS PostgreSQL (Original - mantido para compatibilidade)
resource "aws_db_instance" "golunch_postgres" {
  identifier             = "golunch-postgres"
  engine                 = "postgres"
  engine_version         = "17"
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

# Nova instância RDS PostgreSQL para Core Service
resource "aws_db_instance" "golunch_core_postgres" {
  identifier             = "golunch-core-prod"
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "golunch_core"
  username               = var.core_db_username
  password               = var.core_db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    Name    = "golunch-core-database"
    Service = "core"
  }
}

# DynamoDB Table para Payment Service
resource "aws_dynamodb_table" "golunch_payment" {
  name         = "golunch-payment"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "golunch-payment-dynamodb"
    Service = "payment"
  }
}

# IAM Policy para acesso ao DynamoDB Payment
resource "aws_iam_policy" "dynamodb_payment_access" {
  name        = "DynamoDBPaymentAccess"
  description = "Permite acesso à tabela DynamoDB de pagamentos para o Payment Service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.golunch_payment.arn,
          "${aws_dynamodb_table.golunch_payment.arn}/index/*"
        ]
      }
    ]
  })

  tags = {
    Name    = "DynamoDBPaymentAccess"
    Service = "payment"
  }
}

# Outputs para DynamoDB
output "dynamodb_table_name" {
  description = "DynamoDB table name for Payment Service"
  value       = aws_dynamodb_table.golunch_payment.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN for Payment Service"
  value       = aws_dynamodb_table.golunch_payment.arn
}

output "dynamodb_table_id" {
  description = "DynamoDB table ID for Payment Service"
  value       = aws_dynamodb_table.golunch_payment.id
}

output "dynamodb_payment_policy_arn" {
  description = "ARN da IAM Policy para acesso ao DynamoDB Payment (use este ARN no microserviço de pagamentos)"
  value       = aws_iam_policy.dynamodb_payment_access.arn
}

# Output da URL de conexão (Original)
output "database_url" {
  value = aws_db_instance.golunch_postgres.address
}

# Outputs para Core Service
output "core_database_url" {
  description = "Core Service database endpoint"
  value       = aws_db_instance.golunch_core_postgres.address
}

output "core_database_port" {
  description = "Core Service database port"
  value       = aws_db_instance.golunch_core_postgres.port
}

output "core_database_name" {
  description = "Core Service database name"
  value       = aws_db_instance.golunch_core_postgres.db_name
}
