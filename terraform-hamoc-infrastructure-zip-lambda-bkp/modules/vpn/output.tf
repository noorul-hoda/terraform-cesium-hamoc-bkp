output "sts_vpn_id" {
  value = join("", aws_vpn_connection.sts-vpn.*.id)
}