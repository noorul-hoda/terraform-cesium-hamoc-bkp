resource "aws_iam_instance_profile" "ec2-etl" {
  name = "${local.prefix}-ec2-etl-${local.suffix}"
  role = aws_iam_role.ec2-etl.name
}

resource "aws_iam_role" "ec2-etl" {
  name = "${local.prefix}-ec2-etl-${local.suffix}"
  max_session_duration = 7200
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ec2-etl-bulkload" {
  name   = "${local.prefix}-ec2-etl-bulkload-${local.suffix}"
  role   = aws_iam_role.ec2-etl.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "${var.bulk-load-s3_arn}",
                "${var.bulk-load-s3_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                 "kms:Decrypt",
                 "kms:GenerateDataKey"
             ],
            "Resource": [
                    "*"
             ]
        }
    ]
}
POLICY
}
