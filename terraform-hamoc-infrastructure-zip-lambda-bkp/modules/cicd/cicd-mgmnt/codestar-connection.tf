resource "aws_codestarconnections_connection" "bitbucket" {
  name          = "${local.prefix}-bitbucket-${local.suffix}"
  provider_type = "Bitbucket"
}