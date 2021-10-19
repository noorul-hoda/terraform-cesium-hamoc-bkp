#####################
##Basic Lambda Policy
#####################

resource "aws_iam_policy" "basic_lambda_execution_policy" {
  name   = "${local.prefix}-basic_lambda_execution_policy-${local.suffix}"
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
  },
  {
    "Effect": "Allow",
    "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
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
  }
]
}
EOF
}

###########################
##dataingestion_lambda_role
###########################

resource "aws_iam_role" "dataingestion_lambda_role" {
  name               = "${local.prefix}-dataingestion-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_dataingestion" {
  role       = aws_iam_role.dataingestion_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "dataingestion_lambda_policy" {
  name   = "${local.prefix}-dataingestion_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dataingestion_lambda_policy" {
  role       = aws_iam_role.dataingestion_lambda_role.name
  policy_arn = aws_iam_policy.dataingestion_lambda_policy.arn
}

###########################
##inforeq_lambda_role
###########################

resource "aws_iam_role" "inforeq_lambda_role" {
  name               = "${local.prefix}-inforeq-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_inforeq" {
  role       = aws_iam_role.inforeq_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "inforeq_lambda_policy" {
  name   = "${local.prefix}-inforeq_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "inforeq_lambda_policy" {
  role       = aws_iam_role.inforeq_lambda_role.name
  policy_arn = aws_iam_policy.inforeq_lambda_policy.arn
}

###########################
##searchengine_lambda_role
###########################

resource "aws_iam_role" "searchengine_lambda_role" {
  name               = "${local.prefix}-searchengine-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_searchengine" {
  role       = aws_iam_role.searchengine_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "searchengine_lambda_policy" {
  name   = "${local.prefix}-searchengine_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "searchengine_lambda_policy" {
  role       = aws_iam_role.searchengine_lambda_role.name
  policy_arn = aws_iam_policy.searchengine_lambda_policy.arn
}

###########################
##notificationCenter_lambda_role
###########################

resource "aws_iam_role" "notificationCenter_lambda_role" {
  name               = "${local.prefix}-notificationCenter-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_notificationCenter" {
  role       = aws_iam_role.notificationCenter_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "notificationCenter_lambda_policy" {
  name   = "${local.prefix}-notificationCenter_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "notificationCenter_lambda_policy" {
  role       = aws_iam_role.notificationCenter_lambda_role.name
  policy_arn = aws_iam_policy.notificationCenter_lambda_policy.arn
}

###########################
##accountManagement_lambda_role
###########################

resource "aws_iam_role" "accountManagement_lambda_role" {
  name               = "${local.prefix}-accountManagement-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_accountManagement" {
  role       = aws_iam_role.accountManagement_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "accountManagement_lambda_policy" {
  name   = "${local.prefix}-accountManagement_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
         "cognito-idp:CreateGroup",
         "cognito-idp:CreateIdentityProvider",
         "cognito-idp:CreateUserPool",
         "cognito-idp:CreateUserPoolClient",
         "cognito-idp:DeleteGroup",
         "cognito-idp:DeleteIdentityProvider",
         "cognito-idp:DeleteUserPool",
         "cognito-idp:ChangePassword",
         "cognito-idp:DeleteUserPoolClient",
         "cognito-idp:AdminCreateUser",
         "cognito-idp:AdminDeleteUser",
         "cognito-idp:AdminAddUserToGroup",
         "cognito-idp:AdminRemoveUserFromGroup",
         "cognito-idp:DescribeUserPool",
         "cognito-idp:DescribeUserPoolClient",
         "cognito-idp:AdminListGroupsForUser",
         "cognito-idp:ListUsers",
         "cognito-idp:AdminGetUser",
         "cognito-idp:AdminSetUserPassword",
         "cognito-idp:AdminUpdateUserAttributes"
    ],
      "Resource": "*"
},
  {
      "Effect": "Allow",
      "Action": [
         "cognito-identity:CreateIdentityPool",
         "cognito-identity:DeleteIdentityPool",
         "cognito-identity:SetIdentityPoolRoles",
         "cognito-identity:DescribeIdentityPool"
    ],
       "Resource": "*"
},
{
    "Effect": "Allow",
    "Action": [
         "iam:PassRole",
         "iam:CreateRole",
         "iam:PutRolePolicy",
         "iam:GetRolePolicy",
         "iam:DeleteRole",
         "iam:GetRole",
         "iam:DeleteRolePolicy"
    ],
    "Resource": "*"
}  
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "accountManagement_lambda_policy" {
  role       = aws_iam_role.accountManagement_lambda_role.name
  policy_arn = aws_iam_policy.accountManagement_lambda_policy.arn
}

###########################
##dataManagement_lambda_role
###########################

resource "aws_iam_role" "dataManagement_lambda_role" {
  name               = "${local.prefix}-dataManagement-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_dataManagement" {
  role       = aws_iam_role.dataManagement_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "dataManagement_lambda_policy" {
  name   = "${local.prefix}-dataManagement_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    },
    {
        "Effect": "Allow",
        "Action": "dynamodb:*",
        "Resource": "*"
    }  
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dataManagement_lambda_policy" {
  role       = aws_iam_role.dataManagement_lambda_role.name
  policy_arn = aws_iam_policy.dataManagement_lambda_policy.arn
}

###########################
##userProfile_lambda_role
###########################

resource "aws_iam_role" "userProfile_lambda_role" {
  name               = "${local.prefix}-userProfile-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_userProfile" {
  role       = aws_iam_role.userProfile_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "userProfile_lambda_policy" {
  name   = "${local.prefix}-userProfile_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "userProfile_lambda_policy" {
  role       = aws_iam_role.userProfile_lambda_role.name
  policy_arn = aws_iam_policy.userProfile_lambda_policy.arn
}

###########################
##orgManagement_lambda_role
###########################

resource "aws_iam_role" "orgManagement_lambda_role" {
  name               = "${local.prefix}-orgManagement-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_orgManagement" {
  role       = aws_iam_role.orgManagement_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "orgManagement_lambda_policy" {
  name   = "${local.prefix}-orgManagement_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "orgManagement_lambda_policy" {
  role       = aws_iam_role.orgManagement_lambda_role.name
  policy_arn = aws_iam_policy.orgManagement_lambda_policy.arn
}

###########################
##externalapi_lambda_role
###########################

resource "aws_iam_role" "externalapi_lambda_role" {
  name               = "${local.prefix}-externalapi-lambda_role-${local.suffix}"
  assume_role_policy = file("${path.module}/lambda-assume-policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_externalapi" {
  role       = aws_iam_role.externalapi_lambda_role.name
  policy_arn = aws_iam_policy.basic_lambda_execution_policy.arn
}

resource "aws_iam_policy" "externalapi_lambda_policy" {
  name   = "${local.prefix}-externalapi_lambda_policy-${local.suffix}"
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${var.landing_bucket_name}",
         "arn:aws:s3:::${var.landing_bucket_name}/*", 
         "arn:aws:s3:::${var.raw_bucket_name}",
         "arn:aws:s3:::${var.raw_bucket_name}/*",                           
         "arn:aws:s3:::${var.compute_bucket_name}",
         "arn:aws:s3:::${var.compute_bucket_name}/*",
         "arn:aws:s3:::${var.analytics_bucket_name}",
         "arn:aws:s3:::${var.analytics_bucket_name}/*"       
      ]
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "externalapi_lambda_policy" {
  role       = aws_iam_role.externalapi_lambda_role.name
  policy_arn = aws_iam_policy.externalapi_lambda_policy.arn
}
