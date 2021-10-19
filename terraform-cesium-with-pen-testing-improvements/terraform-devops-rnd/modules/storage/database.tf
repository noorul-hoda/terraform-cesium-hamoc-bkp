## RDS databases
// RDS postgreSQL engine
// DB Subnet groups
// SSM parameters

resource "aws_db_subnet_group" "sg-rds-postgre" {
  name       = "${local.prefix}-sg-rds-${local.suffix}"
  subnet_ids = flatten(["${var.subnets_priv_id}"])
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-rds-postgre-${local.suffix}" })
  )
}

# RDS instance
resource "aws_db_instance" "rds-postgre" {
  identifier              = "${local.prefix}-rds-db-${local.suffix}"
  name                    = "postgresdb"
  allocated_storage       = 50
  max_allocated_storage   = 200
  storage_type            = "gp2"
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_id
  engine                  = "postgres"
  engine_version          = "12.7"
  instance_class          = var.db_instance_class
  db_subnet_group_name    = aws_db_subnet_group.sg-rds-postgre.name
  username                = var.db-username
  password                = var.db-password
  backup_retention_period = local.suffix == "dev" ? 30 : 0
  #multi_az                = local.suffix == "prod" ? true : false //commenting since no HA is required
  multi_az               = false
  skip_final_snapshot    = true
  vpc_security_group_ids = ["${var.sg-rds-id}"]
  deletion_protection = true
  apply_immediately = true

  lifecycle {
    ignore_changes = [availability_zone]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rds-db-${local.suffix}" })
  )
}


# SSM Parameters

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "rds-postgre-address" {
  name   = "/${local.prefix}/${local.suffix}/rds-postgre-address"
  type   = "SecureString"
  value  = aws_db_instance.rds-postgre.address
  key_id = data.aws_kms_alias.ssm.arn
}

resource "aws_ssm_parameter" "rds-postgre-username" {
  name   = "/${local.prefix}/${local.suffix}/rds-postgre-username"
  type   = "SecureString"
  value  = var.db-username
  key_id = data.aws_kms_alias.ssm.arn
}

resource "aws_ssm_parameter" "rds-postgre-password" {
  name   = "/${local.prefix}/${local.suffix}/rds-postgre-password"
  type   = "SecureString"
  value  = var.db-password
  key_id = data.aws_kms_alias.ssm.arn
}
