resource "aws_codestarconnections_connection" "connection" {
  name          = "${local.prefix}-${var.name}-${local.suffix}"
  provider_type = var.provider_type
}