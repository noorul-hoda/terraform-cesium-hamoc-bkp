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


resource "aws_lambda_permission" "externalapi" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.externalapi_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/externalapi/*"
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

resource "aws_lambda_permission" "uploadtos3" {
  depends_on    = [aws_api_gateway_rest_api.api]
  action        = "lambda:InvokeFunction"
  function_name = var.uploadtos3_fn_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/uploadtos3/*"
  qualifier     = local.suffix
}

