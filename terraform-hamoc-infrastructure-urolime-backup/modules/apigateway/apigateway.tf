##API Gateway Resources and methods
resource "aws_api_gateway_rest_api" "api" {
  name        = "${local.prefix}-api-gateway-${local.suffix}"
  description = "FastAPI application"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "api" {
  name          = "${local.prefix}-CognitoUserPoolAuthorizer-${local.suffix}"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  provider_arns = toset([var.cognito-user-pool_arn])
}

##########################
###dataingestion Resources
##########################

resource "aws_api_gateway_resource" "dataingestion" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dataingestion"
}

resource "aws_api_gateway_resource" "dataingestion_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.dataingestion.id
  path_part   = "{proxy+}"
}

#dataingestion PROXY-ANY

resource "aws_api_gateway_method" "dataingestion_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "dataingestion_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method             = aws_api_gateway_method.dataingestion_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.dataingestion_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "dataingestion_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.dataingestion_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method = aws_api_gateway_method.dataingestion_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#dataingestion PROXY-OPTIONS

resource "aws_api_gateway_method" "dataingestion_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "dataingestion_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method = aws_api_gateway_method.dataingestion_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "dataingestion_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method          = aws_api_gateway_method.dataingestion_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "dataingestion_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.dataingestion_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataingestion_ProxyResource.id
  http_method = aws_api_gateway_method.dataingestion_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.dataingestion_ProxyResource-OPTIONS.status_code
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

##########################
###inforeq Resources
##########################

resource "aws_api_gateway_resource" "inforeq" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "inforeq"
}

resource "aws_api_gateway_resource" "inforeq_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.inforeq.id
  path_part   = "{proxy+}"
}

#inforeq PROXY-ANY

resource "aws_api_gateway_method" "inforeq_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "inforeq_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method             = aws_api_gateway_method.inforeq_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.inforeq_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "inforeq_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.inforeq_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method = aws_api_gateway_method.inforeq_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#inforeq PROXY-OPTIONS

resource "aws_api_gateway_method" "inforeq_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "inforeq_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method = aws_api_gateway_method.inforeq_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "inforeq_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method          = aws_api_gateway_method.inforeq_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "inforeq_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.inforeq_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.inforeq_ProxyResource.id
  http_method = aws_api_gateway_method.inforeq_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.inforeq_ProxyResource-OPTIONS.status_code
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

##########################
###searchengine Resources
##########################

resource "aws_api_gateway_resource" "searchengine" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "searchengine"
}

resource "aws_api_gateway_resource" "searchengine_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.searchengine.id
  path_part   = "{proxy+}"
}

#searchengine PROXY-ANY

resource "aws_api_gateway_method" "searchengine_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "searchengine_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method             = aws_api_gateway_method.searchengine_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.searchengine_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "searchengine_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.searchengine_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method = aws_api_gateway_method.searchengine_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#searchengine PROXY-OPTIONS

resource "aws_api_gateway_method" "searchengine_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "searchengine_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method = aws_api_gateway_method.searchengine_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "searchengine_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method          = aws_api_gateway_method.searchengine_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "searchengine_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.searchengine_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.searchengine_ProxyResource.id
  http_method = aws_api_gateway_method.searchengine_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.searchengine_ProxyResource-OPTIONS.status_code
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

##########################
###notificationCenter Resources
##########################

resource "aws_api_gateway_resource" "notificationCenter" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "notificationCenter"
}

resource "aws_api_gateway_resource" "notificationCenter_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.notificationCenter.id
  path_part   = "{proxy+}"
}

#notificationCenter PROXY-ANY

resource "aws_api_gateway_method" "notificationCenter_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "notificationCenter_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method             = aws_api_gateway_method.notificationCenter_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.notificationCenter_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "notificationCenter_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.notificationCenter_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method = aws_api_gateway_method.notificationCenter_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#notificationCenter PROXY-OPTIONS

resource "aws_api_gateway_method" "notificationCenter_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "notificationCenter_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method = aws_api_gateway_method.notificationCenter_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "notificationCenter_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method          = aws_api_gateway_method.notificationCenter_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "notificationCenter_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.notificationCenter_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.notificationCenter_ProxyResource.id
  http_method = aws_api_gateway_method.notificationCenter_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.notificationCenter_ProxyResource-OPTIONS.status_code
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

##########################
###accountManagement Resources
##########################

resource "aws_api_gateway_resource" "accountManagement" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "accountManagement"
}

resource "aws_api_gateway_resource" "accountManagement_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.accountManagement.id
  path_part   = "{proxy+}"
}

#accountManagement PROXY-ANY

resource "aws_api_gateway_method" "accountManagement_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "accountManagement_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method             = aws_api_gateway_method.accountManagement_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.accountManagement_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "accountManagement_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.accountManagement_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method = aws_api_gateway_method.accountManagement_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#accountManagement PROXY-OPTIONS

resource "aws_api_gateway_method" "accountManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "accountManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method = aws_api_gateway_method.accountManagement_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "accountManagement_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method          = aws_api_gateway_method.accountManagement_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "accountManagement_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.accountManagement_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.accountManagement_ProxyResource.id
  http_method = aws_api_gateway_method.accountManagement_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.accountManagement_ProxyResource-OPTIONS.status_code
  response_templates = {
    "application/json" = <<EOF
  EOF
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,x-amz-date,Authorization,X-Api-Key,sec-ch-ua-platform,sec-ch-ua-mobile,sec-ch-ua,Referer,Accept,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

}

##########################
###dataManagement Resources
##########################

resource "aws_api_gateway_resource" "dataManagement" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dataManagement"
}

resource "aws_api_gateway_resource" "dataManagement_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.dataManagement.id
  path_part   = "{proxy+}"
}

#dataManagement PROXY-ANY

resource "aws_api_gateway_method" "dataManagement_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "dataManagement_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method             = aws_api_gateway_method.dataManagement_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.dataManagement_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "dataManagement_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.dataManagement_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method = aws_api_gateway_method.dataManagement_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#dataManagement PROXY-OPTIONS

resource "aws_api_gateway_method" "dataManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "dataManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method = aws_api_gateway_method.dataManagement_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "dataManagement_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method          = aws_api_gateway_method.dataManagement_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "dataManagement_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.dataManagement_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.dataManagement_ProxyResource.id
  http_method = aws_api_gateway_method.dataManagement_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.dataManagement_ProxyResource-OPTIONS.status_code
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

##########################
###userProfile Resources
##########################

resource "aws_api_gateway_resource" "userProfile" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "userProfile"
}

resource "aws_api_gateway_resource" "userProfile_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.userProfile.id
  path_part   = "{proxy+}"
}

#userProfile PROXY-ANY

resource "aws_api_gateway_method" "userProfile_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "userProfile_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method             = aws_api_gateway_method.userProfile_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.userProfile_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "userProfile_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.userProfile_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method = aws_api_gateway_method.userProfile_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#userProfile PROXY-OPTIONS

resource "aws_api_gateway_method" "userProfile_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "userProfile_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method = aws_api_gateway_method.userProfile_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "userProfile_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method          = aws_api_gateway_method.userProfile_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "userProfile_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.userProfile_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.userProfile_ProxyResource.id
  http_method = aws_api_gateway_method.userProfile_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.userProfile_ProxyResource-OPTIONS.status_code
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

##########################
###orgManagement Resources
##########################

resource "aws_api_gateway_resource" "orgManagement" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "orgManagement"
}

resource "aws_api_gateway_resource" "orgManagement_ProxyResource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.orgManagement.id
  path_part   = "{proxy+}"
}

#orgManagement PROXY-ANY

resource "aws_api_gateway_method" "orgManagement_ProxyResource-ANY" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method = "ANY"


  request_parameters = {
    "method.request.path.proxy" = true
  }

  authorization = "AWS_IAM"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "orgManagement_ProxyResource-ANY" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method             = aws_api_gateway_method.orgManagement_ProxyResource-ANY.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.orgManagement_invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]

}

resource "aws_api_gateway_integration_response" "orgManagement_ProxyResource-ANY" {
  depends_on  = [aws_api_gateway_integration.orgManagement_ProxyResource-ANY]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method = aws_api_gateway_method.orgManagement_ProxyResource-ANY.http_method
  status_code = "200"
  response_templates = {
    "application/json" = <<EOF
    EOF
  }
}

#orgManagement PROXY-OPTIONS

resource "aws_api_gateway_method" "orgManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method = "OPTIONS"


  request_parameters = {}

  authorization = "NONE"
  #authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_method_response" "orgManagement_ProxyResource-OPTIONS" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method = aws_api_gateway_method.orgManagement_ProxyResource-OPTIONS.http_method
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

resource "aws_api_gateway_integration" "orgManagement_ProxyResource-OPTIONS" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method          = aws_api_gateway_method.orgManagement_ProxyResource-OPTIONS.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "orgManagement_ProxyResource-OPTIONS" {
  depends_on  = [aws_api_gateway_integration.orgManagement_ProxyResource-OPTIONS]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.orgManagement_ProxyResource.id
  http_method = aws_api_gateway_method.orgManagement_ProxyResource-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.orgManagement_ProxyResource-OPTIONS.status_code
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

##API GW Domain name

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.api-domain-name
  regional_certificate_arn = var.acm_website_cert_arn
  security_policy          = "TLS_1_2"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-api-domain-${local.suffix}" })
  )
}

##API GW R53 Record

data "aws_route53_zone" "hosted-zone" {
  name         = var.website-domain-main
  private_zone = false
}

resource "aws_route53_record" "api" {
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.hosted-zone.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}

##API GW Base Mapping
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}