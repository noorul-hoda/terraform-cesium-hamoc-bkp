##API Gateway CW Log Group

resource "aws_cloudwatch_log_group" "apigw-access" {
  name              = "${local.prefix}-apigw-access-${local.suffix}"
  retention_in_days = 60
}

##API GW Account Settings

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.apigw-cloudwatch.arn
}

##API GW IAM Role

resource "aws_iam_role" "apigw-cloudwatch" {
  name = "${local.prefix}-apigw-cloudwatch-${local.suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apigw-cloudwatch-policy" {
  role       = aws_iam_role.apigw-cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
