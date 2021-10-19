resource "aws_codepipeline" "codepipeline" {
  name     = "${local.prefix}-${var.name}-${local.suffix}"
  role_arn = var.role_arn

  artifact_store {
    location = var.artifact_store["location"]
    type     = var.artifact_store["type"]

    encryption_key {
      id   = var.encryption_key["id"]
      type = var.encryption_key["type"]
    }
  }

  dynamic "stage" {
    for_each = [for s in var.stages : {
      name   = s.name
      action = s.action
    } if(lookup(s, "enabled", true))]

    content {
      name = stage.value.name
      action {
        name             = stage.value.action["name"]
        owner            = stage.value.action["owner"]
        version          = stage.value.action["version"]
        category         = stage.value.action["category"]
        provider         = stage.value.action["provider"]
        input_artifacts  = lookup(stage.value.action, "input_artifacts", [])
        output_artifacts = lookup(stage.value.action, "output_artifacts", [])
        configuration    = lookup(stage.value.action, "configuration", {})
        role_arn         = lookup(stage.value.action, "role_arn", null)
        run_order        = lookup(stage.value.action, "run_order", null)
      }
    }
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.name}-${local.suffix}" }
    )
  )
}
