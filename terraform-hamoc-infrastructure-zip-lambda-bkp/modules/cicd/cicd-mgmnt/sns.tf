resource "aws_sns_topic" "approval_sns" {
  name = upper("${local.prefix}_Deploy_Approval_${local.suffix}")

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-Deploy-${local.suffix}" })
  )
}

resource "aws_sns_topic" "pipeline_updates" {
  name = upper("${local.prefix}_codepipeline_updates_${local.suffix}")

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-codepipeline-updates-${local.suffix}" })
  )  
}

resource "aws_sns_topic_policy" "pipeline_updates" {
  arn    = aws_sns_topic.pipeline_updates.arn
  policy = data.aws_iam_policy_document.pipeline_updates_policy.json
}

data "aws_iam_policy_document" "pipeline_updates_policy" {
  statement {
    sid    = "${local.prefix}-cw-eventrule-${local.suffix}-"
    effect = "Allow"
    resources = [
      aws_sns_topic.pipeline_updates.arn
    ]

    principals {
      identifiers = [
        "events.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "SNS:Publish"
    ]
  }
}