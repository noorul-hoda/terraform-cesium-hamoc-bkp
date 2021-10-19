//RDS postgres, Lambda, ECS, ECS ALB, Bastion security group

## Bastion host SG
resource "aws_security_group" "sg-bastion-host" {
  name        = "${local.prefix}-sg-bastion-host-${local.suffix}"
  description = "Bastion host SG"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"
  lifecycle {
    ignore_changes = [ingress]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [var.myip]
    description = "Noor IP"
  }
  
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-bastion-${local.suffix}" }
    )
  )
}

##EC2 ETL SG

resource "aws_security_group" "sg-ec2-etl" {
  name        = "${local.prefix}-sg-ec2-etl-${local.suffix}"
  description = "EC2 ETL SG"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"
  lifecycle {
    ignore_changes = [ingress]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    security_groups = [
      aws_security_group.sg-bastion-host.id
    ]
    description = "Access from bastion host"
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-ec2-etl-${local.suffix}" }
    )
  )
}

## RDS instance SG
resource "aws_security_group" "sg-rds" {
  name        = "${local.prefix}-sg-rds-${local.suffix}"
  description = "Allow access to RDS database instance"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"


  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    description = "PostgreSQL access from within VPC"
    security_groups = [
      aws_security_group.sg-bastion-host.id,
      aws_security_group.sg-ecs.id,
      aws_security_group.sg-lambda.id,
      aws_security_group.sg-ec2-etl.id,
      aws_security_group.sg-codebuild.id
    ]
  }
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-rds-${local.suffix}" }
    )
  )
}

## Lambda SG
resource "aws_security_group" "sg-lambda" {
  name        = "${local.prefix}-sg-lambda-${local.suffix}"
  description = "Lambda SG"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"

  ingress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
    description = "Allow all access inside VPC"
  }
  
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-lambda-${local.suffix}" }
    )
  )
}

#ecs-alb-sg

resource "aws_security_group" "sg-alb" {
  name   = "${local.prefix}-sg-alb-${local.suffix}"
  vpc_id = aws_vpc.vpc.id
   
   ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      =  "${formatlist("%s/32", concat(aws_nat_gateway.nat-gateway.*.public_ip))}"
   description      = "Allow access from NAT Gateway"
  }
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      =  "${formatlist("%s/32", concat(aws_nat_gateway.nat-gateway.*.public_ip))}"
   description      = "Allow access from NAT Gateway"
  }

  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = flatten(["${var.alb_whitelist_ipv4-list}"])
   ipv6_cidr_blocks = flatten(["${var.alb_whitelist_ipv6-list}"])
   description      = "Allow access from Trusted IPs"
  }
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = flatten(["${var.alb_whitelist_ipv4-list}"])
   ipv6_cidr_blocks = flatten(["${var.alb_whitelist_ipv6-list}"])
   description      = "Allow access from Trusted IPs"
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-alb-${local.suffix}" })
  )
}

#ecs-sg

resource "aws_security_group" "sg-ecs" {
  name                   = "${local.prefix}-sg-ecs-${local.suffix}"
  description            = "ECS SG"
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-alb.id]
    description     = "Access from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-ecs-${local.suffix}" }
    )
  )
}

##ML

resource "aws_security_group" "sg-sagemaker" {
  name        = "${local.prefix}-sg-sagemaker-${local.suffix}"
  description = "Sagemaker SG"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"

  ingress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
    description = "Allow all access inside VPC"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-sagemaker-${local.suffix}" }
    )
  )
}

##Codebuild SG

resource "aws_security_group" "sg-codebuild" {
  name        = "${local.prefix}-sg-codebuild-${local.suffix}"
  description = "Codebuild SG"
  vpc_id      = aws_vpc.vpc.id
  revoke_rules_on_delete = "true"

  ingress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "Allow all access inside VPC"
  }
  
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sg-codebuild-${local.suffix}" }
    )
  )
}