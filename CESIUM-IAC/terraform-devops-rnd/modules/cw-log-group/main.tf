resource "aws_cloudwatch_log_group" "this" {
  count = var.create ? 1 : 0

  name              = "${local.prefix}-${var.name}-${local.suffix}"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
}
