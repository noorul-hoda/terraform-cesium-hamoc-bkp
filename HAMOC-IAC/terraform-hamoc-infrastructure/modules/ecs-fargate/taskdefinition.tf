//ECS Taskdefinition

resource "aws_ecs_task_definition" "taskdefinition" {
  family                   = "${local.prefix}-${var.taskdefinition}-${local.suffix}"
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions    = data.template_file.container_definition.rendered

  lifecycle {
      ignore_changes = [
        requires_compatibilities,
        cpu,
        memory,
        execution_role_arn,
        container_definitions,
      ]
    }
}


data "template_file" "container_definition" {
  template = file("${path.module}/container-definition.json.tpl")
  vars = {
    "name"          = "${local.prefix}-${var.taskdefinition}-${local.suffix}",
    "image"         = aws_ecr_repository.fargate-ecr.repository_url
    "region"        = data.aws_region.current.name,
    "loggroup"      = aws_cloudwatch_log_group.ecs-loggroup.name,
    "stream"        = aws_cloudwatch_log_group.ecs-loggroup.name,
    "containerport" = 80,
    "environment"   = jsonencode(var.environment_variables)
    "secrets"       = jsonencode(var.secrets)
  }
}