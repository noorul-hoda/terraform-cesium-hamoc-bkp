output "ecs_clustername" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_servicename" {
  value = aws_ecs_service.ecs-service.name
}

output "ecs_alb_arn" {
  value = aws_alb.ecs.arn
}

output "ecs_alb_tg_arn" {
  value = aws_alb_target_group.ecs-tg.arn
}

output "ecs_alb_arn_suffix" {
  value = aws_alb.ecs.arn_suffix
}

output "ecs_alb_tg_arn_suffix" {
  value = aws_alb_target_group.ecs-tg.arn_suffix
}

output "ecs_alb_dns_name" {
  value = aws_alb.ecs.dns_name
}