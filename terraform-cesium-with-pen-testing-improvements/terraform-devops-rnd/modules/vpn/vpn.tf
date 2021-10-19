//Customer GW
//VPN GW
//VPN GW Route Propagation
//VPN Connection
//VPN Connection Route

resource "aws_customer_gateway" "cgw" {
  count      = local.suffix == "dev" ? 0 : 1
  bgp_asn    = 65000
  ip_address = var.cgw-onprem-ip
  type       = "ipsec.1"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-cgw-${local.suffix}" })
  )
}

resource "aws_vpn_gateway" "vpn-gw" {
  count  = local.suffix == "dev" ? 0 : 1
  vpc_id = var.vpc-id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpn-gw-${local.suffix}" })
  )
}

resource "aws_vpn_gateway_route_propagation" "vpn-gw-route-propagation-pub" {
  count          = local.suffix == "dev" ? 0 : 1
  vpn_gateway_id = aws_vpn_gateway.vpn-gw[0].id
  route_table_id = var.route_table_pub_id
}

resource "aws_vpn_gateway_route_propagation" "vpn-gw-route-propagation-priv" {
  count          = local.suffix == "dev" ? 0 : 1
  vpn_gateway_id = aws_vpn_gateway.vpn-gw[0].id
  route_table_id = var.route_table_priv_id
}

resource "aws_vpn_connection" "sts-vpn" {
  count                = local.suffix == "dev" ? 0 : 1
  vpn_gateway_id       = aws_vpn_gateway.vpn-gw[0].id
  customer_gateway_id  = aws_customer_gateway.cgw[0].id
  type                 = "ipsec.1"
  static_routes_only   = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sts-vpn-${local.suffix}" })
  )
}

resource "aws_vpn_connection_route" "sts-vpn-route" {
  for_each               = toset(var.onprem-cidr-block)
  destination_cidr_block = each.key
  vpn_connection_id      = aws_vpn_connection.sts-vpn[0].id
}
