//API Gateway
//Lambda Permission

data "aws_lambda_function" "existing_lambdas" {
  for_each      = toset(var.lambda_for_api)
  function_name = "${local.prefix}-${each.key}-${local.suffix}"
  #qualifier     = local.suffix
  depends_on = [aws_lambda_function.lambda_functions]
}

resource "aws_api_gateway_rest_api" "apiLambda" {
  name        = "${local.prefix}-api-gateway-${local.suffix}"
  description = "Demo version of the CESIUM FastAPI application used as an example for setting up the infrastructure"
  depends_on  = [aws_lambda_function.lambda_functions]

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "apiLambda" {
  count         = local.suffix == "dev" ? 0 : 1
  name          = "${local.prefix}-CognitoUserPoolAuthorizer-${local.suffix}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  provider_arns = toset([var.cognito-user-pool_arn])
}

resource "aws_api_gateway_method" "apiLambda" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = "ANY"


  request_parameters = {}

  authorization = local.suffix == "dev" ? "NONE" : "COGNITO_USER_POOLS"
  authorizer_id = local.suffix == "dev" ? null : aws_api_gateway_authorizer.apiLambda[0].id
}

resource "aws_api_gateway_method_response" "apiLambda" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = aws_api_gateway_method.apiLambda.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "apiLambda" {
  for_each                = toset(var.lambda_for_api)
  rest_api_id             = aws_api_gateway_rest_api.apiLambda.id
  resource_id             = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method             = aws_api_gateway_method.apiLambda.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = data.aws_lambda_function.existing_lambdas["api"].invoke_arn
}

resource "aws_api_gateway_integration_response" "apiLambda" {
  depends_on  = [aws_api_gateway_integration.apiLambda]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_rest_api.apiLambda.root_resource_id
  http_method = aws_api_gateway_method.apiLambda.http_method
  status_code = aws_api_gateway_method_response.apiLambda.status_code
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

##Proxy

resource "aws_api_gateway_resource" "apiLambda_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "{proxy+}"
}

##PROXY-ANY
resource "aws_api_gateway_method" "apiLambda_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = local.suffix == "dev" ? "NONE" : "COGNITO_USER_POOLS"
  authorizer_id = local.suffix == "dev" ? null : aws_api_gateway_authorizer.apiLambda[0].id
}

resource "aws_api_gateway_integration" "apiLambda_ProxyResource-ANY" {
  for_each                = toset(var.lambda_for_api)
  rest_api_id             = aws_api_gateway_rest_api.apiLambda.id
  resource_id             = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method             = aws_api_gateway_method.apiLambda_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = data.aws_lambda_function.existing_lambdas["api"].invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "apiLambda_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.apiLambda_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}


##PROXY-OPTIONS
resource "aws_api_gateway_method" "apiLambda_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = local.suffix == "prod" ? "NONE" : "COGNITO_USER_POOLS"
  authorizer_id = local.suffix == "prod" ? null : aws_api_gateway_authorizer.apiLambda[0].id
}

resource "aws_api_gateway_method_response" "apiLambda_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_ProxyResource-OPTIONS.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "apiLambda_ProxyResource-OPTIONS" {
  for_each             = toset(var.lambda_for_api)
  rest_api_id          = aws_api_gateway_rest_api.apiLambda.id
  resource_id          = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method          = aws_api_gateway_method.apiLambda_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "apiLambda_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.apiLambda_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_ProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.apiLambda_ProxyResource-OPTIONS.status_code
  response_templates = {
    "application/json" = <<EOF
  EOF
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

}

##ML Resources
resource "aws_api_gateway_resource" "apiLambda_mlResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "ml"
}

#ML-ANY
resource "aws_api_gateway_method" "apiLambda_mlResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = "ANY"


  request_parameters = {}
  authorization      = "AWS_IAM"
}

resource "aws_api_gateway_method_response" "apiLambda_mlResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = aws_api_gateway_method.apiLambda_mlResource-ANY.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "apiLambda_mlResource-ANY" {
  for_each             = toset(var.lambda_for_api)
  rest_api_id          = aws_api_gateway_rest_api.apiLambda.id
  resource_id          = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method          = aws_api_gateway_method.apiLambda_mlResource-ANY.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "apiLambda_mlResource-ANY" {
  depends_on  = [aws_api_gateway_integration.apiLambda_mlResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = aws_api_gateway_method.apiLambda_mlResource-ANY.http_method
  status_code = aws_api_gateway_method_response.apiLambda_mlResource-ANY.status_code
  response_templates = {
    "application/json" = <<EOF
  EOF
  }
}

#ML-Options

resource "aws_api_gateway_method" "apiLambda_mlResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = "OPTIONS"


  request_parameters = {}
  authorization      = "AWS_IAM"
}

resource "aws_api_gateway_method_response" "apiLambda_mlResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = aws_api_gateway_method.apiLambda_mlResource-OPTIONS.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "apiLambda_mlResource-OPTIONS" {
  for_each             = toset(var.lambda_for_api)
  rest_api_id          = aws_api_gateway_rest_api.apiLambda.id
  resource_id          = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method          = aws_api_gateway_method.apiLambda_mlResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "apiLambda_mlResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.apiLambda_mlResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlResource.id
  http_method = aws_api_gateway_method.apiLambda_mlResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.apiLambda_mlResource-OPTIONS.status_code
  response_templates = {
    "application/json" = <<EOF
  EOF
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

}

#ML Proxy
resource "aws_api_gateway_resource" "apiLambda_mlProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_resource.apiLambda_mlResource.id
  path_part   = "{proxy+}"
}

#ML Proxy ANY
resource "aws_api_gateway_method" "apiLambda_mlProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization      = "AWS_IAM"
}

resource "aws_api_gateway_integration" "apiLambda_mlProxyResource-ANY" {
  for_each                = toset(var.lambda_for_api)
  rest_api_id             = aws_api_gateway_rest_api.apiLambda.id
  resource_id             = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method             = aws_api_gateway_method.apiLambda_mlProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = data.aws_lambda_function.existing_lambdas["api"].invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "apiLambda_mlProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.apiLambda_mlProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_mlProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#ML Proxy Options
resource "aws_api_gateway_method" "apiLambda_mlProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method_response" "apiLambda_mlProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_mlProxyResource-OPTIONS.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Origin"  = false
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "apiLambda_mlProxyResource-OPTIONS" {
  for_each             = toset(var.lambda_for_api)
  rest_api_id          = aws_api_gateway_rest_api.apiLambda.id
  resource_id          = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method          = aws_api_gateway_method.apiLambda_mlProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "apiLambda_mlProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.apiLambda_mlProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.apiLambda_mlProxyResource.id
  http_method = aws_api_gateway_method.apiLambda_mlProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.apiLambda_mlProxyResource-OPTIONS.status_code
  response_templates = {
    "application/json" = <<EOF
  EOF
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

}

resource "aws_api_gateway_deployment" "apiLambda" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.apiLambda.id,
      aws_api_gateway_integration.apiLambda["api"].id,
      aws_api_gateway_resource.apiLambda_ProxyResource.id,
      aws_api_gateway_method.apiLambda_ProxyResource-ANY.id,
      aws_api_gateway_integration.apiLambda_ProxyResource-ANY["api"].id,
      aws_api_gateway_method.apiLambda_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.apiLambda_ProxyResource-OPTIONS["api"].id,

      aws_api_gateway_resource.apiLambda_mlResource.id,
      aws_api_gateway_method.apiLambda_mlResource-ANY.id,
      aws_api_gateway_integration.apiLambda_mlResource-ANY["api"].id,
      aws_api_gateway_method.apiLambda_mlResource-OPTIONS.id,
      aws_api_gateway_integration.apiLambda_mlResource-OPTIONS["api"].id,
      
      aws_api_gateway_resource.apiLambda_mlProxyResource.id,
      aws_api_gateway_method.apiLambda_mlProxyResource-ANY.id,
      aws_api_gateway_integration.apiLambda_mlProxyResource-ANY["api"].id,
      aws_api_gateway_method.apiLambda_mlProxyResource-OPTIONS.id,
      aws_api_gateway_integration.apiLambda_mlProxyResource-OPTIONS["api"].id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "apigw-execution" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.apiLambda.id}/${local.suffix}"
  retention_in_days = 60
}

resource "aws_api_gateway_stage" "apiLambda" {
  depends_on = [
    aws_cloudwatch_log_group.apigw-access,
    aws_api_gateway_account.account,
    aws_cloudwatch_log_group.apigw-execution
  ]
  deployment_id = aws_api_gateway_deployment.apiLambda.id
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  stage_name    = local.suffix

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw-access.arn
    format          = "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\",\"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
  }
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = aws_api_gateway_stage.apiLambda.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = "true"
  }
}

##Lambda permission
resource "aws_lambda_permission" "apiLambda" {
  depends_on    = [aws_api_gateway_rest_api.apiLambda]
  action        = "lambda:InvokeFunction"
  for_each      = toset(var.lambda_for_api)
  function_name = data.aws_lambda_function.existing_lambdas["api"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apiLambda-ml" {
  depends_on    = [aws_api_gateway_rest_api.apiLambda]
  action        = "lambda:InvokeFunction"
  for_each      = toset(var.lambda_for_api)
  function_name = data.aws_lambda_function.existing_lambdas["api"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*/ml/*"
}

##API GW Domain name
resource "aws_api_gateway_domain_name" "apiLambda" {
  domain_name              = var.api-domain-name
  regional_certificate_arn = var.acm-website-cert-arn
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-api-domain-${local.suffix}" })
  )
}

##R53

data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

resource "aws_route53_record" "apiLambda" {
  name    = aws_api_gateway_domain_name.apiLambda.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted-zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.apiLambda.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.apiLambda.regional_zone_id
  }
}

##API GW Base Mapping
resource "aws_api_gateway_base_path_mapping" "apiLambda" {
  api_id      = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = aws_api_gateway_stage.apiLambda.stage_name
  domain_name = aws_api_gateway_domain_name.apiLambda.domain_name
}

##Commenting since only one lambda resource
# resource "aws_api_gateway_rest_api" "apiLambda" {
#   name        = "${local.prefix}-api-gateway-${local.suffix}"
#   depends_on = [data.aws_lambda_function.existing_lambdas]
# }

# resource "aws_api_gateway_resource" "proxy" {

#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
#   for_each = toset(var.lambda_for_api)
#   path_part   = data.aws_lambda_function.existing_lambdas["api"].function_name
# }

# resource "aws_api_gateway_method" "proxyMethod" {
#   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id   = aws_api_gateway_resource.proxy["api"].id
#   http_method   = "POST"
#   
# }

# resource "aws_api_gateway_method" "proxyMethod_option" {
#   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id   = aws_api_gateway_resource.proxy["api"].id
#   http_method   = "OPTIONS"
#   
# }

# resource "aws_api_gateway_integration" "lambda" {
#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id = aws_api_gateway_method.proxyMethod["api"].resource_id
#   http_method = aws_api_gateway_method.proxyMethod["api"].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"

#   uri                     = data.aws_lambda_function.existing_lambdas["api"].invoke_arn
# }

# resource "aws_api_gateway_integration" "lambda_option" {
#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id = aws_api_gateway_method.proxyMethod_option["api"].resource_id
#   http_method = aws_api_gateway_method.proxyMethod_option["api"].http_method
# //  integration_http_method = "OPTIONS"
#   type                    = "MOCK"

# //  uri                     = data.aws_lambda_function.existing_lambdas["api"].invoke_arn
# }


# resource "aws_api_gateway_method_response" "option_response_200" {
#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id = aws_api_gateway_resource.proxy["api"].id
#   http_method = aws_api_gateway_method.proxyMethod_option["api"].http_method
#   status_code = "200"
# }

# resource "aws_api_gateway_integration_response" "option_IntegrationResponse" {
#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   for_each = toset(var.lambda_for_api)
#   resource_id = aws_api_gateway_resource.proxy["api"].id
#   http_method = aws_api_gateway_method.proxyMethod_option["api"].http_method
#   status_code = aws_api_gateway_method_response.option_response_200["api"].status_code

# }
# resource "aws_api_gateway_deployment" "apideploy" {
#   depends_on = [
#     aws_api_gateway_integration.lambda,
#    aws_api_gateway_integration.lambda_option
#   ]

#   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
#   stage_name  = "${local.suffix}"
# }


# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   for_each = toset(var.lambda_for_api)
#   function_name = data.aws_lambda_function.existing_lambdas["api"].function_name
#   principal     = "apigateway.amazonaws.com"

#   # The "/*/*" portion grants access from any method on any resource
#   # within the API Gateway REST API.
#   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/*"
# }
