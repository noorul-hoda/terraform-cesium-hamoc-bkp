//Alerts SNS

resource "aws_sns_topic" "alert_sns" {
  name = upper("${local.prefix}_Alerts_${local.suffix}")
}