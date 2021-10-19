//Lambda ECR Repository
//ECR Repository Lifecycle

resource "aws_ecr_repository" "lambda_ecr" {
  for_each      = toset(var.lambda_list)
  name          = lower("${local.prefix}-${each.key}-${local.suffix}")

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  for_each      = toset(var.lambda_list)
  repository    = aws_ecr_repository.lambda_ecr[each.key].name

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