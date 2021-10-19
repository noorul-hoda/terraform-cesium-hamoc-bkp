output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets_pub_id" {
  value = aws_subnet.public-subnet.*.id
}

output "subnets_priv_id" {
  value = aws_subnet.private-subnet.*.id
}

output "bastion_host_instance_id" {
  value = aws_instance.bastion-host.id
}

output "bastion_host_sg_id" {
  value = aws_security_group.sg-bastion-host.id
}

output "nat_gw_public_ip" {
  value = aws_nat_gateway.nat-gateway.*.public_ip
}

output "sg_lambda_id" {
  value = aws_security_group.sg-lambda.id
}

output "sg_ecs_id" {
  value = aws_security_group.sg-ecs.id
}

output "sg_alb_id" {
  value = aws_security_group.sg-alb.id
}

output "sg_rds_id" {
  value = aws_security_group.sg-rds.id
}

output "sg_neptune_id" {
  value = aws_security_group.sg-neptune.id
}

output "sg_elasticsearch_id" {
  value = aws_security_group.sg-elasticsearch.id
}

output "sg_codebuild_id" {
  value = aws_security_group.sg-codebuild.id
}

output "route_table_pub_id" {
  value = aws_route_table.rt-public.*.id
}

output "route_table_priv_id" {
  value = aws_route_table.rt-private.*.id
}