resource "aws_iam_role" "cloudtrail_cw_events_role" {
  name               = "${local.prefix}-cloudtrail_events_role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}  
EOF
}

resource "aws_iam_role_policy" "cloudtrail_cw_events_policy" {
  name        = "${local.prefix}-cloudtrail_events_policy-${local.suffix}"    
  role        = aws_iam_role.cloudtrail_cw_events_role.id
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.cloudtrail_loggroup.arn}:log-stream:*"
            ]
        }
    ]
}
POLICY
}

