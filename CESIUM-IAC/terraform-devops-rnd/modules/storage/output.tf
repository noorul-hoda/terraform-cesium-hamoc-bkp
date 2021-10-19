output "sagemaker-bucket-arn" {
  value = aws_s3_bucket.sagemaker-bucket.arn
}

output "sagemaker-bucket-name" {
  value = aws_s3_bucket.sagemaker-bucket.bucket
}

output "sagemaker-bucket-id" {
  value = aws_s3_bucket.sagemaker-bucket.id
}

output "lambda-packages-bucket-arn" {
  value = aws_s3_bucket.lambda-packages.arn
}

output "lambda-packages-bucket-name" {
  value = aws_s3_bucket.lambda-packages.bucket
}

output "db-host-address" {
  value = aws_db_instance.rds-postgre.address
}

output "db-host-name" {
  value = aws_db_instance.rds-postgre.name
}

output "db-host-identifier" {
  value = aws_db_instance.rds-postgre.identifier
}

output "rds-postgre-address-ssm_arn" {
  value = aws_ssm_parameter.rds-postgre-address.arn
}

output "rds-postgre-username-ssm_arn" {
  value = aws_ssm_parameter.rds-postgre-username.arn
}

output "rds-postgre-password-ssm_arn" {
  value = aws_ssm_parameter.rds-postgre-password.arn
}

output "bulk-load-s3_arn" {
  value = aws_s3_bucket.bulk-load.arn
}

output "update-routine-bucket-id" {
  value = aws_s3_bucket.update-routine-bucket.id
}