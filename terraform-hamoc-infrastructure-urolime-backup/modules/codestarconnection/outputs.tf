output "connection_arn" {
  description = "CodestarConnection ARNs"
  value       = aws_codestarconnections_connection.connection.arn
}