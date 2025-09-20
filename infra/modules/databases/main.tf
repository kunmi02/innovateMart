resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Allow database traffic from EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db-sg"
  }
}

# PostgreSQL RDS for orders service
resource "aws_db_instance" "postgresql" {
  identifier             = "${var.name}-postgresql"
  engine                 = "postgres"
  engine_version         = "16.10"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "orders"
  username               = "postgres"
  password               = random_password.postgresql_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  
  tags = {
    Name = "${var.name}-postgresql"
  }
}

# MySQL RDS for catalog service
resource "aws_db_instance" "mysql" {
  identifier             = "${var.name}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "catalog"
  username               = "admin"
  password               = random_password.mysql_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  
  tags = {
    Name = "${var.name}-mysql"
  }
}

# DynamoDB for carts service
resource "aws_dynamodb_table" "carts" {
  name           = "${var.name}-carts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  tags = {
    Name = "${var.name}-carts"
  }
}

# Generate random passwords
resource "random_password" "postgresql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "postgresql" {
  name = "${var.name}-postgresql-credentials"
  
  tags = {
    Name = "${var.name}-postgresql-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "postgresql" {
  secret_id = aws_secretsmanager_secret.postgresql.id
  secret_string = jsonencode({
    username = aws_db_instance.postgresql.username
    password = random_password.postgresql_password.result
    host     = aws_db_instance.postgresql.address
    port     = aws_db_instance.postgresql.port
    dbname   = aws_db_instance.postgresql.db_name
  })
}

resource "aws_secretsmanager_secret" "mysql" {
  name = "${var.name}-mysql-credentials"
  
  tags = {
    Name = "${var.name}-mysql-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({
    username = aws_db_instance.mysql.username
    password = random_password.mysql_password.result
    host     = aws_db_instance.mysql.address
    port     = aws_db_instance.mysql.port
    dbname   = aws_db_instance.mysql.db_name
  })
}

resource "aws_secretsmanager_secret" "dynamodb" {
  name = "${var.name}-dynamodb-credentials"
  
  tags = {
    Name = "${var.name}-dynamodb-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "dynamodb" {
  secret_id = aws_secretsmanager_secret.dynamodb.id
  secret_string = jsonencode({
    table_name = aws_dynamodb_table.carts.name
  })
}
