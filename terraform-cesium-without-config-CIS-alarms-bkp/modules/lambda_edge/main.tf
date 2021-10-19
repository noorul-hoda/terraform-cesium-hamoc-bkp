data "archive_file" "lambda_zip" {
  count = var.create_lambda_edge ? 1 : 0
  type  = "zip"
  source_dir  = var.lambda_edge_code_dir
  output_path = "./lambda_edge_code/${var.lambda-edge-name}.zip"
}

resource "aws_lambda_function" "edge_lambda" {
  count            = var.create_lambda_edge ? 1 : 0
  function_name    = "${local.prefix}-${var.lambda-edge-name}-${local.suffix}"
  filename         = "./lambda_edge_code/${var.lambda-edge-name}.zip"
  handler          = var.handler
  runtime          = var.runtime
  publish          = "true"
  source_code_hash = data.archive_file.lambda_zip[count.index].output_base64sha256
  role             = var.create_iam_role ? aws_iam_role.lambda_edge_role[count.index].arn : var.iam_role_arn
}

resource "aws_iam_role" "lambda_edge_role" {
  count              = var.create_lambda_edge && var.create_iam_role ? 1 : 0
  name               = "${local.prefix}-${var.lambda-edge-name}-role-${local.suffix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_edge_policy" {
  count  = var.create_lambda_edge && var.create_iam_role ? 1 : 0
  name   = "${local.prefix}-${var.lambda-edge-name}-role-policy-${local.suffix}"
  role   = aws_iam_role.lambda_edge_role[0].id
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ],
      "Resource": "*"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  count      = var.create_lambda_edge && var.create_iam_role ? 1 : 0
  role       = aws_iam_role.lambda_edge_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}