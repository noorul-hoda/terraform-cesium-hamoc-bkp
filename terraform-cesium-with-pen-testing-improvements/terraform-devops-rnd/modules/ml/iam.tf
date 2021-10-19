##Lambda IAM

resource "aws_iam_role" "ml_lambda_role" {
  name               = "${local.prefix}-ml_lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/templates/policy/lambda-assume-policy.json")
}

resource "aws_iam_policy" "ml_lambda_policy" {
  name   = "${local.prefix}-ml_lambda_policy-${local.suffix}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeSecurityGroups",
                "ec2:AttachNetworkInterface",
                "sagemaker:*",
                "iam:PassRole"
            ],
            "Resource": "*"
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
        },
        {
            "Action": "s3:*",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.update-routine-bucket-id}",
                "arn:aws:s3:::${var.update-routine-bucket-id}/*",
                "arn:aws:s3:::${var.sagemaker-bucket-id}",
                "arn:aws:s3:::${var.sagemaker-bucket-id}/*"

            ]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ml_lambda_policy" {
  role       = aws_iam_role.ml_lambda_role.name
  policy_arn = aws_iam_policy.ml_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.ml_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##Updatepredictions IAM role

# resource "aws_iam_role" "ml_UpdatePredictions_lambda_role" {
#   name               = "${local.prefix}-ml_UpdatePredictions_lambda_role-${local.suffix}"
#   assume_role_policy = file("${path.module}/templates/policy/lambda-assume-policy.json")
# }

# resource "aws_iam_policy" "ml_UpdatePredictions_lambda_policy" {
#   name = "${local.prefix}-ml_UpdatePredictions_lambda_access_policy-${local.suffix}"
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:DescribeNetworkInterfaces",
#                 "ec2:CreateNetworkInterface",
#                 "ec2:DeleteNetworkInterface",
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeSubnets",
#                 "ec2:DescribeVpcs",
#                 "ec2:DescribeSecurityGroups",
#                 "ec2:AttachNetworkInterface",
#                 "sagemaker:*",
#                 "iam:PassRole"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Action": "s3:*",
#             "Effect": "Allow",
#             "Resource": [
#                "arn:aws:s3:::${var.update-routine-bucket-id}",
#                "arn:aws:s3:::${var.update-routine-bucket-id}/*"
#             ]
#         }
#     ]
# }
# POLICY

# }

# resource "aws_iam_role_policy_attachment" "ml_UpdatePredictions_lambda_policy" {
#   role       = aws_iam_role.ml_UpdatePredictions_lambda_role.name
#   policy_arn = aws_iam_policy.ml_UpdatePredictions_lambda_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "ml_sagemaker_AWSLambdaBasicExecutionRole" {
#   role       = aws_iam_role.ml_UpdatePredictions_lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

##Sagemaker instance IAM

resource "aws_iam_role" "sagemaker-role" {
  name = "${local.prefix}-sagemaker-role-${local.suffix}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sagemaker.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sagemaker-execution-role-policy" {
  name        = "${local.prefix}-sagemaker-execution-policy-${local.suffix}"
  description = "${local.prefix}-sagemaker-execution-role-policy-${local.suffix}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
               "kms:Decrypt",
               "kms:GenerateDataKey"
           ],
           "Resource": [
                "*"
           ]
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "${var.sagemaker-bucket-arn}"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "${var.sagemaker-bucket-arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sagemaker-execution-role-policy" {
  role       = aws_iam_role.sagemaker-role.name
  policy_arn = aws_iam_policy.sagemaker-execution-role-policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker-full-access" {
  role       = aws_iam_role.sagemaker-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}