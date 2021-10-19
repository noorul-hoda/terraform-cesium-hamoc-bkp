//ECS Loggroup
//ECS Cluster
//ECS Service
//Autoscaling target/policies

resource "aws_cloudwatch_log_group" "ecs-loggroup" {
  name              = "${local.prefix}-ecs-loggroup-${local.suffix}"
  retention_in_days = 60
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.prefix}-${var.cluster-name}-${local.suffix}"
}

data "aws_ecs_task_definition" "taskdefinition" {
  task_definition = aws_ecs_task_definition.taskdefinition.family
  depends_on      = [aws_ecs_task_definition.taskdefinition]
}

resource "aws_ecs_service" "ecs-service" {
  name    = "${local.prefix}-${var.ecs-service}-${local.suffix}"
  cluster = aws_ecs_cluster.cluster.id
  #task_definition                    = aws_ecs_task_definition.taskdefinition.arn
  task_definition                    = "${aws_ecs_task_definition.taskdefinition.family}:${max("${aws_ecs_task_definition.taskdefinition.revision}", "${data.aws_ecs_task_definition.taskdefinition.revision}")}"
  desired_count                      = local.suffix == "prod" ? 2 : 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [var.sg-ecs-id]
    subnets          = flatten(["${var.subnets_priv_id}"])
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs-tg.arn
    container_name   = "${local.prefix}-${var.taskdefinition}-${local.suffix}"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = local.suffix == "prod" ? 2 : 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 60
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
