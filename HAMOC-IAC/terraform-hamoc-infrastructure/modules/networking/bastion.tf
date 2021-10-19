#bastion instance
resource "aws_instance" "bastion-host" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg-bastion-host.id]

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion-host-${local.suffix}" }
    )
  )
}