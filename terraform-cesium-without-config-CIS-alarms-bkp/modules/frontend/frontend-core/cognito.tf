## Cognito Authentication and Authorization
# user-pool resource
# user-identity
# IAM role & policy
# SSM parameters

# USER-POOL RESOURCE
resource "aws_cognito_user_pool" "cognito-user-pool" {
  name = "${local.prefix}-cogito-user-pool-${local.suffix}"



  # ATTRIBUTES
  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name                = "email"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  # PASSWORD POLICY
  password_policy {
    minimum_length                   = "12"
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 2
  }

  admin_create_user_config {
    allow_admin_create_user_only = true

    # INVITE MESSAGE CUSTOMIZATIONS
    invite_message_template {
      sms_message           = "Hello {username}, your temporary password for the CESIUM app is {####}"
      email_subject         = "Invite to join the ${local.prefix} app!"
      email_message         = "Hello {username}, you have been invited to join the ${local.prefix} app! Your temporary password is {####}"
    }
  }

  # MFA & VERIFICATIONS
  mfa_configuration          = "ON"
  sms_authentication_message = "Your MFA code for ${local.prefix} login is {####}."
  sms_verification_message   = "You login has been verified for ${local.prefix} {####}."

  software_token_mfa_configuration {
    enabled = true
  }



  sms_configuration {
    external_id    = "${local.prefix}-cognito-identity-pool-${local.suffix}"
    sns_caller_arn = aws_iam_role.SMS-Role.arn
  }

  user_pool_add_ons {
    advanced_security_mode = "AUDIT"
  }


  #Recovery mechanism:
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    //    recovery_mechanism {
    //      name     = "verified_phone_number"
    //      priority = 2
    //    }
  }

  # MESSAGE CUSTOMIZATIONS
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_subject = "Verify your ${local.prefix} account"
    email_message = "The verification code for your ${local.prefix} account is {####}"
  }
  # email_configuration {
  #   reply_to_email_address = "noorul.hoda@trilateralresearch.com"
  # }

  # DEVICES
  #device_configuration {
  #  challenge_required_on_new_device      = true
  #  device_only_remembered_on_user_prompt = true
  #}

  dynamic "sms_configuration" {
    for_each = var.sms_configuration != null ? [var.sms_configuration] : []

    content {
      external_id    = lookup(var.sms_configuration, "external_id", null)
      sns_caller_arn = lookup(var.sms_configuration, "sns_caller_arn", null)
    }
  }
  # TAGS
  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-cognito-user-pool-${local.suffix}" }
  )
  )
}


# DOMAIN NAME
resource "aws_cognito_user_pool_domain" "cognito-user-pool-domain" {
  depends_on = [
    aws_route53_record.website-url
  ]
  domain          = "auth.${var.website-domain-main}"
  user_pool_id    = aws_cognito_user_pool.cognito-user-pool.id
  certificate_arn = aws_acm_certificate.acm-website-cert.arn
}

# USER-POOL-CLIENT RESOURCE
resource "aws_cognito_user_pool_client" "cognito-user-pool-client" {
  user_pool_id = aws_cognito_user_pool.cognito-user-pool.id
  prevent_user_existence_errors = "ENABLED"

  access_token_validity                = 5
  allowed_oauth_flows_user_pool_client = true
  id_token_validity                    = 5

  allowed_oauth_flows = [
    "code",
    "implicit",
  ]
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "phone",
    "profile",
  ]
  explicit_auth_flows = [
   # "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "minutes"
  }

  # APP CLIENTS
  name                   = "${local.prefix}-app-client-${local.suffix}"
  refresh_token_validity = 60
  read_attributes        = ["email"]
  write_attributes       = ["email"]

  ## APP INTEGRATION
  # APP CLIENT SETTINGS
  supported_identity_providers = ["COGNITO"]
  callback_urls = ["https://${var.website-domain-main}"]
  logout_urls   = ["https://${var.website-domain-main}/signout"]
}



# COGNITO IDENTITY POOL RESOURCE
resource "aws_cognito_identity_pool" "cognito-identity-pool" {
  identity_pool_name               = "${local.prefix}-cognito-identity-pool-${local.suffix}"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito-user-pool-client.id
    provider_name           = aws_cognito_user_pool.cognito-user-pool.endpoint
    server_side_token_check = false
  }
  //  supported_login_providers = {
  //    "graph.facebook.com" = "<your App ID goes here. Refer to picture at the top>"
  //  }

  tags = merge(
  local.common_tags,
  tomap({ "Name" = "${local.prefix}-cognito-identity-pool-${local.suffix}" }
  )
  )
}

resource "aws_iam_role" "SMS-Role" {
  name               = "${local.prefix}-SMS-Role-${local.suffix}"
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cognito-idp.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "${local.prefix}-cognito-identity-pool-${local.suffix}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "SMS-Role-Policy" {
  name = "${local.prefix}-SMS-Role-Policy-${local.suffix}"
  role = aws_iam_role.SMS-Role.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:publish"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
POLICY

}

data "aws_iam_policy_document" "cognito-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cognito-role" {
  name               = "${var.environment}-cognito-role"
  assume_role_policy = data.aws_iam_policy_document.cognito-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "cognito-policy" {
  role       = aws_iam_role.cognito-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

# IDENTITY POOL ROLES
//resource "aws_cognito_identity_pool_roles_attachment" "cognito_identity_pool_roles" {
//  identity_pool_id = aws_cognito_identity_pool.cognito-identity-pool.id
//
//  roles = {
//    "authenticated"   = aws_iam_role.api_gateway_access.arn
//    "unauthenticated" = aws_iam_role.deny_everything.arn
//  }
//}
//
//resource "aws_iam_role_policy" "api_gateway_access" {
//  name   = "api-gateway-access"
//  role   = aws_iam_role.api_gateway_access.id
//  policy = data.aws_iam_policy_document.api_gateway_access.json
//}
//
//resource "aws_iam_role" "api_gateway_access" {
//  name = "ap-gateway-access"
//
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "Federated": "cognito-identity.amazonaws.com"
//      },
//      "Action": "sts:AssumeRoleWithWebIdentity",
//      "Condition": {
//        "StringEquals": {
//          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.cognito-identity-pool.id}"
//        },
//        "ForAnyValue:StringLike": {
//          "cognito-identity.amazonaws.com:amr": "authenticated"
//        }
//      }
//    }
//  ]
//}
//EOF
//}
//
//data "aws_iam_policy_document" "api_gateway_access" {
//  version = "2012-10-17"
//  statement {
//    actions = [
//      "execute-api:Invoke"
//    ]
//
//    effect = "Allow"
//
//    resources = ["arn:aws:execute-api:*:*:*"]
//  }
//}

//resource "aws_iam_role_policy" "deny_everything" {
//  name   = "deny_everything"
//  role   = aws_iam_role.deny_everything.id
//  policy = data.aws_iam_policy_document.deny_everything.json
//}

//resource "aws_iam_role" "deny_everything" {
//  name = "deny_everything"
//  # This will grant the role the ability for cognito identity to assume it
//  assume_role_policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "Federated": "cognito-identity.amazonaws.com"
//      },
//      "Action": "sts:AssumeRoleWithWebIdentity",
//      "Condition": {
//        "StringEquals": {
//          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.cognito-identity-pool.id}"
//        },
//        "ForAnyValue:StringLike": {
//          "cognito-identity.amazonaws.com:amr": "unauthenticated"
//        }
//      }
//    }
//  ]
//}
//EOF
//}
//data "aws_iam_policy_document" "deny_everything" {
//  version = "2012-10-17"
//
//  statement {
//    actions = ["*"]
//    effect    = "Deny"
//    resources = ["*"]
//  }
//}














