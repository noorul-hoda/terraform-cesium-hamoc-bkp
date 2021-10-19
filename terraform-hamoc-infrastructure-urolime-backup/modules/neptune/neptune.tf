##Neptune Cluster Parameter Group

resource "aws_neptune_cluster_parameter_group" "neptune-cluster-pg" {
  family = "neptune1"
  name   = "${local.prefix}-${var.name}-cluster-pg-${local.suffix}"

  dynamic "parameter" {
  for_each = var.parameter
  content {
      name     = parameter.value.name
      value    = parameter.value.value
  }
  }
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-cluster-pg-${local.suffix}" }
    )
  )
}

##Neptune Subnet Group

resource "aws_neptune_subnet_group" "neptune-sg" {
  name       = "${local.prefix}-${var.name}-sg-${local.suffix}"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-sg-${local.suffix}" }
    )
  )
}

resource "aws_neptune_cluster" "neptune-cluster" {
  cluster_identifier                   = "${local.prefix}-${var.name}-cluster-${local.suffix}"
  apply_immediately                    = var.cluster_apply_immediately
  availability_zones                   = data.aws_availability_zones.available.names
  enable_cloudwatch_logs_exports       = ["audit"]
  engine                               = var.cluster_engine
  iam_database_authentication_enabled  = var.cluster_iam_database_authentication_enabled
  iam_roles                            = []
  kms_key_arn                          = var.kms_key_arn
  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.neptune-cluster-pg.name
  neptune_subnet_group_name            = aws_neptune_subnet_group.neptune-sg.name
  port                                 = 8182
  storage_encrypted                    = true
  backup_retention_period              = var.cluster_backup_retention_period
  preferred_backup_window              = var.cluster_preferred_backup_window
  preferred_maintenance_window         = var.cluster_preferred_maintenance_window
  skip_final_snapshot                  = var.cluster_skip_final_snapshot
  vpc_security_group_ids               = var.vpc_security_group_ids

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-cluster-${local.suffix}" }
    )
  )
}

resource "aws_neptune_cluster_instance" "neptune-instance" {
  count                        = var.instance_count
  identifier                   = "${local.prefix}-${var.name}-instance-${local.suffix}"
  apply_immediately            = var.instance_apply_immediately
  availability_zone            = ""
  cluster_identifier           = aws_neptune_cluster.neptune-cluster.id
  engine                       = var.instance_engine
  instance_class               = var.instance_class
  neptune_subnet_group_name    = aws_neptune_subnet_group.neptune-sg.name
  port                         = 8182
  publicly_accessible          = var.publicly_accessible
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-instance-${local.suffix}" }
    )
  )
}