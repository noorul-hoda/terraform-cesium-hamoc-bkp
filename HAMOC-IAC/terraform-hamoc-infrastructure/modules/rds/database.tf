##DB Subnet group

resource "aws_db_subnet_group" "sg-rds-postgres" {
  name       = "${local.prefix}-${var.rds_name}-subnet-group-${local.suffix}"
  subnet_ids = var.subnet_ids
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.rds_name}-subnet-group-${local.suffix}" })
  )
}

# RDS instance

resource "aws_db_instance" "rds-postgres" {
  identifier              = "${local.prefix}-${var.rds_name}-${local.suffix}"
  instance_class          = var.db_instance_class
  availability_zone       = var.multi_az ? null : var.availability_zone
  db_subnet_group_name    = aws_db_subnet_group.sg-rds-postgres.name
  username                = var.db-username
  password                = var.db-password
  engine                  = var.engine
  engine_version          = var.engine_version
  storage_type            = var.storage_type
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_id
  backup_retention_period = var.backup_retention_period
  multi_az                = var.multi_az
  skip_final_snapshot     = var.skip_final_snapshot
  vpc_security_group_ids  = var.vpc_security_group_ids
  apply_immediately       = var.apply_immediately

  lifecycle {
    ignore_changes = [availability_zone]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.rds_name}-${local.suffix}" })
  )
}

resource "aws_db_event_subscription" "rds-event-sub" {
  count     = var.create_event_subscription ? 1 : 0
  name      = "${local.prefix}-${var.rds_name}-event-sub-${local.suffix}"
  sns_topic = var.sns_topic

  source_type = var.source_type
  source_ids  = var.source_ids

  event_categories = var.event_categories
}

## SSM Parameters

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "rds-postgres-address" {
  name   = "/${local.prefix}/${local.suffix}/${var.rds_name}-address"
  type   = "SecureString"
  value  = aws_db_instance.rds-postgres.address
  key_id = data.aws_kms_alias.ssm.arn
}

resource "aws_ssm_parameter" "rds-postgres-username" {
  name   = "/${local.prefix}/${local.suffix}/${var.rds_name}-username"
  type   = "SecureString"
  value  = var.db-username
  key_id = data.aws_kms_alias.ssm.arn
}

resource "aws_ssm_parameter" "rds-postgres-password" {
  name   = "/${local.prefix}/${local.suffix}/${var.rds_name}-password"
  type   = "SecureString"
  value  = var.db-password
  key_id = data.aws_kms_alias.ssm.arn
}
