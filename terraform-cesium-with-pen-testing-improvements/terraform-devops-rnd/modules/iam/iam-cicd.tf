##IAM Roles for ECS CICD

resource "aws_iam_role" "ecs-pipeline-role" {
  name = "${local.prefix}-ecs-codepipeline-${local.suffix}"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-pipeline-policy" {
  name = "${local.prefix}-ecs-pipeline-${local.suffix}"
  role = aws_iam_role.ecs-pipeline-role.name

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
POLICY

}

##ECS CodeBuild IAM Roles/Policies

resource "aws_iam_role" "ecs-codebuild-role" {
  name               = "${local.prefix}-ecs-codebuild-role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "ecs-codebuild-policy" {
  name = "${local.prefix}-lambda-build-policy-${local.suffix}"
  role = aws_iam_role.ecs-codebuild-role.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.ecs_pipeline_artifacts_id}",
         "arn:aws:s3:::${var.ecs_pipeline_artifacts_id}/*"
      ]
    },
    {
       "Effect": "Allow",
       "Action": [
          "logs:*"
      ],
       "Resource": [
          "${var.ecs_codebuild_loggroup_arn}",
          "${var.ecs_codebuild_loggroup_arn}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
       ],
      "Resource": ["*"]
    }      
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "ecs-codebuild-role-policy" {
  role       = aws_iam_role.ecs-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "ecs-codebuild-ecr-policy" {
  role = aws_iam_role.ecs-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##IAM roles and Policies for frontend/backend cicd

resource "aws_iam_role" "frontend_backend-pipeline-role" {
  name = "${local.prefix}-frontend_backend-pipeline-${local.suffix}"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "frontend_backend-pipeline-policy" {
  name = "${local.prefix}-frontend_backend-pipeline-${local.suffix}"
  role = aws_iam_role.frontend_backend-pipeline-role.name

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}  
POLICY

}

##Lambda CodeBuild IAM Roles/Policies

resource "aws_iam_role" "lambda-codebuild-role" {
  name               = "${local.prefix}-lambda-codebuild-role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "lambda-codebuild-policy" {
  name = "${local.prefix}-lambda-build-policy-${local.suffix}"
  role = aws_iam_role.lambda-codebuild-role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Effect": "Allow",
     "Action": [
        "lambda:*"
    ],
     "Resource": "*"
    },
    {
     "Effect": "Allow",
     "Action": [
     "ecr:SetRepositoryPolicy",
     "ecr:GetRepositoryPolicy",
     "ecr:InitiateLayerUpload"
    ],
     "Resource": "*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.frontend_backend_pipeline_artifacts_id}",
         "arn:aws:s3:::${var.frontend_backend_pipeline_artifacts_id}/*"
      ]
    },
    {
       "Effect": "Allow",
       "Action": [
          "logs:*"
      ],
       "Resource": [
          "${var.lambda_codebuild_loggroup_arn}",
          "${var.lambda_codebuild_loggroup_arn}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
       ],
      "Resource": ["*"]
    }       
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "lambda-codebuild-role-policy" {
  role       = aws_iam_role.lambda-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy_attachment" "lambda-codebuild-ecr-policy" {
  role = aws_iam_role.lambda-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

##Frontend Codebuild IAM Roles


resource "aws_iam_role" "frontend-codebuild-role" {
  name               = "${local.prefix}-frontend-codebuild-role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "frontend-codebuild-policy" {
  name = "${local.prefix}-frontend-build-policy-${local.suffix}"
  role = aws_iam_role.frontend-codebuild-role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.frontend_backend_pipeline_artifacts_id}",
         "arn:aws:s3:::${var.frontend_backend_pipeline_artifacts_id}/*",
         "arn:aws:s3:::${var.web_bucket_name}",
         "arn:aws:s3:::${var.web_bucket_name}/*"       
      ]
    },
    {
      "Effect": "Allow",
       "Action": [
         "cloudfront:CreateInvalidation"
      ],
       "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": [
          "logs:*"
      ],
       "Resource": [
          "${var.frontend_codebuild_loggroup_arn}",
          "${var.frontend_codebuild_loggroup_arn}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
       ],
      "Resource": ["*"]
    }       
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "frontend-codebuild-role-policy" {
  role       = aws_iam_role.frontend-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

##IAM roles and Policies for ml lambda cicd

resource "aws_iam_role" "ml-lambda-pipeline-role" {
  name = "${local.prefix}-ml-lambda-pipeline-${local.suffix}"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ml-lambda-pipeline-policy" {
  name = "${local.prefix}-ml-lambda-pipeline-${local.suffix}"
  role = aws_iam_role.ml-lambda-pipeline-role.name

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}  
POLICY

}

##ML Lambda CodeBuild IAM Roles/Policies

resource "aws_iam_role" "ml-lambda-codebuild-role" {
  name               = "${local.prefix}-ml-lambda-codebuild-role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "ml-lambda-codebuild-policy" {
  name = "${local.prefix}-ml-lambda-build-policy-${local.suffix}"
  role = aws_iam_role.ml-lambda-codebuild-role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Effect": "Allow",
     "Action": [
        "lambda:*"
    ],
     "Resource": "*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.ml_lambda_pipeline_artifacts_id}",
         "arn:aws:s3:::${var.ml_lambda_pipeline_artifacts_id}/*",
         "arn:aws:s3:::${var.lambda_packages_bucket_name}",
         "arn:aws:s3:::${var.lambda_packages_bucket_name}/*"
      ]
    },
    {
       "Effect": "Allow",
       "Action": [
          "logs:*"
      ],
       "Resource": [
          "${var.ml_lambda_codebuild_loggroup_arn}",
          "${var.ml_lambda_codebuild_loggroup_arn}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
       ],
      "Resource": ["*"]
    }       
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "ml-lambda-codebuild-role-policy" {
  role       = aws_iam_role.ml-lambda-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}