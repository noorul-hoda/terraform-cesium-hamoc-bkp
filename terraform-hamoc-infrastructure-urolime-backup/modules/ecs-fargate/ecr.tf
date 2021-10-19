##ECR Repo for ECS

resource "aws_ecr_repository" "fargate-ecr" {
  name                 = "${local.prefix}-${var.fargate-ecrname}-${local.suffix}"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }
}

##ECR Repo lifecycle

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository    = aws_ecr_repository.fargate-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images when more than ${var.expire_image_count}",
            "selection": {
                "countType": "imageCountMoreThan",
                "countNumber": ${var.expire_image_count},
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


