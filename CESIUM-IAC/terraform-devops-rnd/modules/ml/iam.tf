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
            "Resource": [
                "arn:aws:s3:::${var.update-routine-bucket-id}",
                "arn:aws:s3:::${var.update-routine-bucket-id}/*",
                "arn:aws:s3:::${var.sagemaker-bucket-id}",
                "arn:aws:s3:::${var.sagemaker-bucket-id}/*"]
        },
        {
          "Effect": "Allow",
          "Action": [
                 "kms:Decrypt",
                 "kms:GenerateDataKey"
           ],
            "Resource": [
                "arn:aws:s3:::${var.update-routine-bucket-id}",
                "arn:aws:s3:::${var.update-routine-bucket-id}/*",
                "arn:aws:s3:::${var.sagemaker-bucket-id}",
                "arn:aws:s3:::${var.sagemaker-bucket-id}/*"
           ]
        },
        {
            "Action": [
        "s3:DescribeJob",
        "s3:DescribeMultiRegionAccessPointOperation",
        "s3:GetAccelerateConfiguration",
        "s3:GetAccessPoint",
        "s3:GetAccessPointConfigurationForObjectLambda",
        "s3:GetAccessPointForObjectLambda",
        "s3:GetAccessPointPolicy",
        "s3:GetAccessPointPolicyForObjectLambda",
        "s3:GetAccessPointPolicyStatus",
        "s3:GetAccessPointPolicyStatusForObjectLambda",
        "s3:GetAccountPublicAccessBlock",
        "s3:GetAnalyticsConfiguration",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketLocation",
        "s3:GetBucketLogging",
        "s3:GetBucketNotification",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketOwnershipControls",
        "s3:GetBucketPolicy",
        "s3:GetBucketPolicyStatus",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetBucketWebsite",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:ListBucket",
        "s3:PutAccessPointConfigurationForObjectLambda",
        "s3:PutAccessPointPolicy",
        "s3:PutBucketAcl",
        "s3:PutBucketLogging",
        "s3:PutBucketPolicy",
        "s3:PutObject",
        "s3:PutObjectAcl"
],
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