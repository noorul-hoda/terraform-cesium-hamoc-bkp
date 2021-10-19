output "db_host_address" {
  value = aws_db_instance.rds-postgres.address
}

output "db_host_name" {
  value = aws_db_instance.rds-postgres.name
}

output "db_host_identifier" {
  value = aws_db_instance.rds-postgres.identifier
}

output "rds_postgres_address_ssm_arn" {
  value = aws_ssm_parameter.rds-postgres-address.arn
}

output "rds_postgres_username_ssm_arn" {
  value = aws_ssm_parameter.rds-postgres-username.arn
}

output "rds_postgres_password_ssm_arn" {
  value = aws_ssm_parameter.rds-postgres-password.arn
}