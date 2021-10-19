//IAM roles and Policies

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
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
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
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
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
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
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
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
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
         "arn:aws:s3:::${aws_s3_bucket.frontend_backend-pipeline-artifacts.id}",
         "arn:aws:s3:::${aws_s3_bucket.frontend_backend-pipeline-artifacts.id}/*"
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
         "arn:aws:s3:::${aws_s3_bucket.frontend_backend-pipeline-artifacts.id}",
         "arn:aws:s3:::${aws_s3_bucket.frontend_backend-pipeline-artifacts.id}/*",
         "arn:aws:s3:::${var.web-bucket-name}",
         "arn:aws:s3:::${var.web-bucket-name}/*"       
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
    }    
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "frontend-codebuild-role-policy" {
  role       = aws_iam_role.frontend-codebuild-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}