##CW Event rule

resource "aws_cloudwatch_event_rule" "cw-event-rule" {
  name           = "${local.prefix}-${var.name}-${local.suffix}"
  is_enabled     = var.cw_event_rule_is_enabled
  description    = var.cw_event_rule_description != "" ? var.cw_event_rule_description : null
  event_bus_name = var.event_bus_name
  event_pattern  = var.cw_event_rule_pattern
}

##CW Event Target

resource "aws_cloudwatch_event_target" "cw-event-rule-target" {
  rule       = aws_cloudwatch_event_rule.cw-event-rule.name
  arn        = var.arn

  dynamic "input_transformer" {
    for_each = length(keys(var.input_transformer)) == 0 ? [] : [var.input_transformer]
    content {
      input_paths        = lookup(input_transformer.value, "input_paths", null)
      input_template     = lookup(input_transformer.value, "input_template", null)
    }
  }

}
