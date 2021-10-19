output "dataingestion_lambda_role_arn" {
  value = aws_iam_role.dataingestion_lambda_role.arn
}

output "inforeq_lambda_role_arn" {
  value = aws_iam_role.inforeq_lambda_role.arn
}

output "searchengine_lambda_role_arn" {
  value = aws_iam_role.searchengine_lambda_role.arn
}

output "notificationCenter_lambda_role_arn" {
  value = aws_iam_role.notificationCenter_lambda_role.arn
}

output "accountManagement_lambda_role_arn" {
  value = aws_iam_role.accountManagement_lambda_role.arn
}

output "dataManagement_lambda_role_arn" {
  value = aws_iam_role.dataManagement_lambda_role.arn 
}

output "userProfile_lambda_role_arn" {
value = aws_iam_role.userProfile_lambda_role.arn
}

output "orgManagement_lambda_role_arn" {
  value = aws_iam_role.orgManagement_lambda_role.arn 
}

output "externalapi_lambda_role_arn" {
  value = aws_iam_role.externalapi_lambda_role.arn 
}