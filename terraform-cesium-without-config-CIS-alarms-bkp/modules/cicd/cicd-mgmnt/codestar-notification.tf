# resource "aws_codestarnotifications_notification_rule" "ecs-pipeline_updates" {
#   detail_type    = "BASIC"
#   event_type_ids = var.event_type_ids
#   name           = "${local.prefix}-ecs-pipeline_updates-${local.suffix}"
#   resource       = var.ecs-pipeline_arn

#   target {
#     address = aws_sns_topic.pipeline_updates.arn
#     type    = "SNS"
#   }

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-ecs-pipeline-${local.suffix}" })
#   )
# }

# resource "aws_codestarnotifications_notification_rule" "front-back-end-pipeline_updates" {
#   detail_type    = "BASIC"
#   event_type_ids = var.event_type_ids
#   name           = "${local.prefix}-frontend-backend-pipeline_updates-${local.suffix}"
#   resource       = var.front-back-end-pipeline_arn

#   target {
#     address = aws_sns_topic.pipeline_updates.arn
#     type    = "SNS"
#   }

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-frontend-backend-pipeline-${local.suffix}" })
#   )
# }