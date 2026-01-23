resource "aws_secretsmanager_secret" "golunch_db_url" {
  name        = "golunch/db-url"
  description = "Endereço do banco de dados da api GoLunch"
}

resource "aws_secretsmanager_secret_version" "golunch_db_url" {
  secret_id     = aws_secretsmanager_secret.golunch_db_url.id
  secret_string = aws_db_instance.golunch_postgres.address
}

resource "aws_secretsmanager_secret" "golunch_core_db_url" {
  name        = "golunch/core-db-url"
  description = "Endereço do banco de dados do Core Service"
}

resource "aws_secretsmanager_secret_version" "golunch_core_db_url" {
  secret_id     = aws_secretsmanager_secret.golunch_core_db_url.id
  secret_string = aws_db_instance.golunch_core_postgres.address
}