##Cognito Authentication and Authorization

# USER-POOL RESOURCE
resource "aws_cognito_user_pool" "cognito-user-pool" {
  name = "${local.prefix}-${var.cognito_pool_name}-${local.suffix}"

  # ATTRIBUTES
  alias_attributes         = ["email", "preferred_username"]
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    name                = "email"
    mutable             = true
    required            = true
    string_attribute_constraints {
      min_length = 7
      max_length = 256
    }
  }

  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = true
    name = "FirstName"
    required = false
    string_attribute_constraints {
      max_length = 256
      min_length = 7
    }
  }
  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = true
    name = "LastName"
    required = false
    string_attribute_constraints {
      max_length = 256
      min_length = 7
    }
  }

  # PASSWORD POLICY
  password_policy {
    minimum_length                   = "10"
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
      sms_message   = "Hello {username}, your temporary password for the HAMOC app is {####}"
      email_subject = "Invite to join the ${local.suffix} app!"
      email_message = "Hello {username}, you have been invited to join the ${local.suffix} app! Your temporary password is {####}"
    }
  }

  # MFA & VERIFICATIONS
  mfa_configuration          = "ON"
  sms_authentication_message = "Your login has been verified for ${local.prefix} and code is {####}."
  sms_verification_message   = "You login has been verified for ${local.prefix} {####}."

  software_token_mfa_configuration {
    enabled = true
  }

  sms_configuration {
    external_id    = "${local.prefix}-${var.cognito_identity_pool_name}-${local.suffix}"
    sns_caller_arn = aws_iam_role.SMS-Role.arn
  }

  user_pool_add_ons {
    advanced_security_mode = "AUDIT"
  }

  # RECOVERY MECHANISM
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = 2
    # }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your ${local.prefix} account"
    email_message        = "The verification code for your ${local.prefix} account is {####}"
  }

  # DEVICES
  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

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
  domain          = "auth.${var.website-domain-main}"
  user_pool_id    = aws_cognito_user_pool.cognito-user-pool.id
  certificate_arn = var.acm_website_cert_arn
}

# USER-POOL-CLIENT RESOURCE
resource "aws_cognito_user_pool_client" "cognito-user-pool-client" {
  user_pool_id                  = aws_cognito_user_pool.cognito-user-pool.id
  prevent_user_existence_errors = "ENABLED"

  access_token_validity                = 60
  allowed_oauth_flows_user_pool_client = true
  id_token_validity                    = 60

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
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # APP CLIENTS
  name                   = "${local.prefix}-app-client-${local.suffix}"
  refresh_token_validity = 30
  read_attributes        = ["email"]
  write_attributes       = ["email"]

  ## APP INTEGRATION
  # APP CLIENT SETTINGS
  supported_identity_providers = ["COGNITO"]
  callback_urls                = ["https://${var.website-domain-main}"]
  logout_urls                  = ["https://${var.website-domain-main}/signout"]
}

# COGNITO IDENTITY POOL RESOURCE
resource "aws_cognito_identity_pool" "cognito-identity-pool" {
  identity_pool_name               = "${local.prefix}_cognito_identity_pool_${local.suffix}"
  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito-user-pool-client.id
    provider_name           = aws_cognito_user_pool.cognito-user-pool.endpoint
    server_side_token_check = false
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-${var.cognito_identity_pool_name}-${local.suffix}" }
    )
  )
}

##IAM Role for SMS

resource "aws_iam_role" "SMS-Role" {
  name               = "${local.prefix}-${var.SMS_Role}-${local.suffix}"
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
          "sts:ExternalId": "${local.prefix}-${var.cognito_identity_pool_name}-${local.suffix}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "SMS-Role-Policy" {
  name = "${local.prefix}-${var.SMS_Role_Policy}-${local.suffix}"
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

resource "aws_iam_role" "cognito-role" {
  name               = "${local.prefix}-${var.cognito_role}-${local.suffix}"
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
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cognito-policy" {
  role       = aws_iam_role.cognito-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}


#R53
data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

resource "aws_route53_record" "auth-cognito-record" {
  name            = aws_cognito_user_pool_domain.cognito-user-pool-domain.domain
  type            = "A"
  zone_id         = data.aws_route53_zone.hosted-zone.zone_id
  allow_overwrite = true
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.cognito-user-pool-domain.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}