//Lambda API IAM user and access policy
//Lambda roles/policies

resource "aws_iam_user" "lambda-apigw-access" {
  name = "${local.prefix}-lambda-apigw-access-${local.suffix}"
  path = "/"
  force_destroy = true
}

resource "aws_iam_access_key" "lambda-apigw-access" {
  user = aws_iam_user.lambda-apigw-access.name
}

resource "aws_iam_user_policy" "lambda-apigw-access" {
  name = "${local.prefix}-lambda-apigw-access-${local.suffix}"
  user = aws_iam_user.lambda-apigw-access.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "execute-api:Invoke"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/*",
        "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/ml/*"
      ]
    }
  ]
}
EOF
}

//Lambda Policies

resource "aws_iam_role" "lambda_role" {
  name               = "${local.prefix}-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda_module/templates/policy/lambda-assume-policy.json")
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.prefix}-lambda_policy-${local.suffix}"
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
      "ec2:AttachNetworkInterface",
      "sagemaker:*"
    ],
      "Resource": "*"
  },
  {
     "Effect": "Allow",
     "Action": "s3:*",
     "Resource": [
       "arn:aws:s3:::${var.update-routine-bucket-id}",
       "arn:aws:s3:::${var.update-routine-bucket-id}/*",
       "arn:aws:s3:::${var.sagemaker-bucket-id}",
       "arn:aws:s3:::${var.sagemaker-bucket-id}/*"
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
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}