## ec2 instances
//create Bastion host - jump box to private instances
//Defined data aws_ami to always fetch the latest AMI
//Dependencies: vpc, security_group & ec2_keypair

resource "aws_key_pair" "ec2-keypair" {
  key_name   = local.suffix
  public_key = file("${path.module}/ssh-keys/${local.suffix}.pub")

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ec2-keypair-${local.suffix}" }
    )
  )
}

data "aws_ami" "ami-london" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion-host" {
  ami                    = data.aws_ami.ami-london.id
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.public-subnet[0].id
  key_name               = aws_key_pair.ec2-keypair.key_name
  vpc_security_group_ids = [aws_security_group.sg-bastion-host.id]
  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-bastion-${local.suffix}" }
    )
  )
}
resource "aws_instance" "ec2-etl" {
  ami                    = data.aws_ami.ami-london.id
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.private-subnet[0].id
  key_name               = aws_key_pair.ec2-keypair.key_name
  vpc_security_group_ids = [aws_security_group.sg-ec2-etl.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-etl.name
  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ec2-etl-${local.suffix}" }
    )
  )
}
