//ECS Taskdefinition

resource "aws_ecs_task_definition" "taskdefinition" {
  family                   = "${local.prefix}-${var.taskdefinition}-${local.suffix}"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn


  container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.fargate-ecr.repository_url}",
    "name": "${local.prefix}-${var.taskdefinition}-${local.suffix}",
    "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "${data.aws_region.current.name}",
                    "awslogs-group" : "${aws_cloudwatch_log_group.ecs-loggroup.name}",
                    "awslogs-stream-prefix" : "${aws_cloudwatch_log_group.ecs-loggroup.name}"
                }
            },
    "secrets": [
           {
               "name": "rds-postgre-address",
               "valueFrom": "${var.rds-postgre-address-ssm_arn}"
           },
           {
               "name": "rds-postgre-username",
               "valueFrom": "${var.rds-postgre-username-ssm_arn}"
           },
           {
               "name": "rds-postgre-password",
               "valueFrom": "${var.rds-postgre-password-ssm_arn}"
           }                       
    ],                  
    "environment": [],
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80
      }
    ]
    }
]
DEFINITION

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
