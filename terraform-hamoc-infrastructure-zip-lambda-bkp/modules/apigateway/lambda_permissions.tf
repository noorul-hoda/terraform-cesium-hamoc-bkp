##Lambda permissions

resource "aws_lambda_permission" "dataingestion" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.dataingestion_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/dataingestion/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "inforeq" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.inforeq_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/inforeq/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "searchengine" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.searchengine_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/searchengine/*"
  qualifier     = local.suffix
}


resource "aws_lambda_permission" "notificationCenter" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.notificationCenter_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/notificationCenter/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "accountManagement" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.accountManagement_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/accountManagement/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "dataManagement" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.dataManagement_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/dataManagement/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "userProfile" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.userProfile_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/userProfile/*"
  qualifier     = local.suffix
}

resource "aws_lambda_permission" "orgManagement" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.orgManagement_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/orgManagement/*"
  qualifier     = local.suffix
}

