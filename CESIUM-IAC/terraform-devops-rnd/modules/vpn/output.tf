output "sts-vpn-id" {
  value = join("", aws_vpn_connection.sts-vpn.*.id)
}