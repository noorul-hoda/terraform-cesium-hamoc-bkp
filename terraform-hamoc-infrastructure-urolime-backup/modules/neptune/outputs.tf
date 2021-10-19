output "neptune_endpoint" {
    value = aws_neptune_cluster.neptune-cluster.endpoint
}

output "neptune_identifier" {
    value = aws_neptune_cluster.neptune-cluster.id
  
}