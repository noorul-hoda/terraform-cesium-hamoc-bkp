output "endpoint" {
  value = aws_elasticsearch_domain.elasticsearch_domain.endpoint
}

output "kibana_endpoint" {
  value = aws_elasticsearch_domain.elasticsearch_domain.kibana_endpoint
}

output "domain_name" {
  value = aws_elasticsearch_domain.elasticsearch_domain.domain_name
}
