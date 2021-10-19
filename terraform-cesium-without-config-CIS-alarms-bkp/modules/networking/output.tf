output "vpc-id" {
  value = aws_vpc.vpc.id
}

output "sg-rds-id" {
  value = aws_security_group.sg-rds.id
}

output "sg-lambda-id" {
  value = aws_security_group.sg-lambda.id
}

output "sg-alb-id" {
  value = aws_security_group.sg-alb.id
}

output "sg-ecs-id" {
  value = aws_security_group.sg-ecs.id
}

output "sg-sagemaker-id" {
  value = aws_security_group.sg-sagemaker.id
}

output "subnets_priv_id" {
  value = aws_subnet.private-subnet.*.id
}

output "subnets_pub_id" {
  value = aws_subnet.public-subnet.*.id
}

output "ec2-etl-instance-id" {
  value = aws_instance.ec2-etl.id
}

output "bastion-host-instance-id" {
  value = aws_instance.bastion-host.id
}

output "route_table_pub_id" {
  value = aws_route_table.rt-public.id
}

output "route_table_priv_id" {
  value = aws_route_table.rt-private.id
}