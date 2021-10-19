resource "aws_sagemaker_notebook_instance" "ml-notebook-instance" {
  name                   = "${local.prefix}-ml-notebook-instance-${local.suffix}"
  role_arn               = aws_iam_role.sagemaker-role.arn
  instance_type          = "ml.t2.medium"
  direct_internet_access = "Disabled"
  subnet_id              = element(flatten([var.subnets_priv_id]), 1)
  security_groups        = [var.sg-sagemaker-id]
  lifecycle_config_name  = aws_sagemaker_notebook_instance_lifecycle_configuration.ml-notebook-instance-lc.name

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }

  depends_on = [
    aws_sagemaker_notebook_instance_lifecycle_configuration.ml-notebook-instance-lc
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ml-notebook-instance-${local.suffix}" }
    )
  )
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "ml-notebook-instance-lc" {
  name      = "${local.prefix}-ml-notebook-instance-lifecycle-${local.suffix}"
  on_create = filebase64("${path.module}/templates/sagemaker-lifecycle/lifecycle")
  on_start  = filebase64("${path.module}/templates/sagemaker-lifecycle/lifecycle")

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
}
