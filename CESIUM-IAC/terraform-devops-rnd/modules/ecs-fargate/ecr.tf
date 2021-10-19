//ECR Repo for ECS
//ECR Repo lifecycle

resource "aws_ecr_repository" "fargate-ecr" {
  name                 = "${local.prefix}-${var.fargate-ecrname}-${local.suffix}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository    = aws_ecr_repository.fargate-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images when more than 1000",
            "selection": {
                "countType": "imageCountMoreThan",
                "countNumber": 1000,
                "tagStatus": "any"
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


