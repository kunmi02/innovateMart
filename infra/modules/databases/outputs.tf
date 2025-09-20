output "postgresql_endpoint" {
  value = aws_db_instance.postgresql.endpoint
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.carts.name
}

output "postgresql_secret_arn" {
  value = aws_secretsmanager_secret.postgresql.arn
}

output "mysql_secret_arn" {
  value = aws_secretsmanager_secret.mysql.arn
}

output "dynamodb_secret_arn" {
  value = aws_secretsmanager_secret.dynamodb.arn
}
