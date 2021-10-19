##API GW Deployment

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([

      aws_api_gateway_resource.dataingestion.id,
      aws_api_gateway_resource.dataingestion_ProxyResource.id,
      aws_api_gateway_resource.dataingestion_ProxyResource.id,
      aws_api_gateway_method.dataingestion_ProxyResource-ANY.id,
      aws_api_gateway_integration.dataingestion_ProxyResource-ANY.id,
      aws_api_gateway_method.dataingestion_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.dataingestion_ProxyResource-OPTIONS.id,

      aws_api_gateway_resource.inforeq.id,
      aws_api_gateway_resource.inforeq_ProxyResource.id,
      aws_api_gateway_resource.inforeq_ProxyResource.id,
      aws_api_gateway_method.inforeq_ProxyResource-ANY.id,
      aws_api_gateway_integration.inforeq_ProxyResource-ANY.id,
      aws_api_gateway_method.inforeq_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.inforeq_ProxyResource-OPTIONS.id,

            
      aws_api_gateway_resource.searchengine.id,
      aws_api_gateway_resource.searchengine_ProxyResource.id,
      aws_api_gateway_resource.searchengine_ProxyResource.id,
      aws_api_gateway_method.searchengine_ProxyResource-ANY.id,
      aws_api_gateway_integration.searchengine_ProxyResource-ANY.id,
      aws_api_gateway_method.searchengine_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.searchengine_ProxyResource-OPTIONS.id,

            
      aws_api_gateway_resource.notificationCenter.id,
      aws_api_gateway_resource.notificationCenter_ProxyResource.id,
      aws_api_gateway_resource.notificationCenter_ProxyResource.id,
      aws_api_gateway_method.notificationCenter_ProxyResource-ANY.id,
      aws_api_gateway_integration.notificationCenter_ProxyResource-ANY.id,
      aws_api_gateway_method.notificationCenter_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.notificationCenter_ProxyResource-OPTIONS.id,

            
      aws_api_gateway_resource.accountManagement.id,
      aws_api_gateway_resource.accountManagement_ProxyResource.id,
      aws_api_gateway_resource.accountManagement_ProxyResource.id,
      aws_api_gateway_method.accountManagement_ProxyResource-ANY.id,
      aws_api_gateway_integration.accountManagement_ProxyResource-ANY.id,
      aws_api_gateway_method.accountManagement_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.accountManagement_ProxyResource-OPTIONS.id,

      aws_api_gateway_resource.dataManagement.id,
      aws_api_gateway_resource.dataManagement_ProxyResource.id,
      aws_api_gateway_resource.dataManagement_ProxyResource.id,
      aws_api_gateway_method.dataManagement_ProxyResource-ANY.id,
      aws_api_gateway_integration.dataManagement_ProxyResource-ANY.id,
      aws_api_gateway_method.dataManagement_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.dataManagement_ProxyResource-OPTIONS.id,

            
      aws_api_gateway_resource.userProfile.id,
      aws_api_gateway_resource.userProfile_ProxyResource.id,
      aws_api_gateway_resource.userProfile_ProxyResource.id,
      aws_api_gateway_method.userProfile_ProxyResource-ANY.id,
      aws_api_gateway_integration.userProfile_ProxyResource-ANY.id,
      aws_api_gateway_method.userProfile_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.userProfile_ProxyResource-OPTIONS.id,

            
      aws_api_gateway_resource.orgManagement.id,
      aws_api_gateway_resource.orgManagement_ProxyResource.id,
      aws_api_gateway_resource.orgManagement_ProxyResource.id,
      aws_api_gateway_method.orgManagement_ProxyResource-ANY.id,
      aws_api_gateway_integration.orgManagement_ProxyResource-ANY.id,
      aws_api_gateway_method.orgManagement_ProxyResource-OPTIONS.id,
      aws_api_gateway_integration.orgManagement_ProxyResource-OPTIONS.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

##API GW Log group

resource "aws_cloudwatch_log_group" "apigw-execution" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${local.suffix}"
  retention_in_days = 60
}

##API GW Stage

resource "aws_api_gateway_stage" "api" {
  depends_on = [
    aws_cloudwatch_log_group.apigw-access,
    aws_api_gateway_account.account,
    aws_cloudwatch_log_group.apigw-execution
  ]
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = local.suffix

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw-access.arn
    format          = "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\":\"$context.identity.caller\", \"user\":\"$context.identity.user\",\"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"resourcePath\":\"$context.resourcePath\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
  }
}

##API GW Method Settings

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = "true"
  }
}