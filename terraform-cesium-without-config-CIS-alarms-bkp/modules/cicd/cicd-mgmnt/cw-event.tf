# //ECS Codepipeline Updates Cloudwatch event rule

resource "aws_cloudwatch_event_rule" "pipeline_updates" {
  name           = "${local.prefix}-codepipeline_updates-${local.suffix}"
  description    = "Capture changes for ${local.prefix}-${local.suffix} pipelines"
  is_enabled     = "true"
  event_bus_name = "default"
  event_pattern  = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "pipeline_updates" {
  arn  = aws_sns_topic.pipeline_updates.arn
  rule = aws_cloudwatch_event_rule.pipeline_updates.name

  input_transformer {
    input_paths = {

      accounts = "$.account",
      branch   = "$.detail.referenceName",
      pipeline = "$.detail.pipeline",
      state    = "$.detail.state"

    }
    input_template = "\"CICD CodePipeline for Name: <pipeline> has <state> for Account: ${local.prefix} ${local.suffix} environment\""

  }
}
