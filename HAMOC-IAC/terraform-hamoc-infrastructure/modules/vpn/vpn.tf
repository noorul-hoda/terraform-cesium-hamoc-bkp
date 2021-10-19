
locals {
  vpn-gw-route-propagation-pub  = var.enabled && var.route_table_pub_id != null ? length(var.route_table_pub_id) : 0
  vpn-gw-route-propagation-priv = var.enabled && var.route_table_priv_id != null ? length(var.route_table_priv_id) : 0
}

##Customer GW

resource "aws_customer_gateway" "cgw" {
  count      = var.enabled ? 1 : 0
  bgp_asn    = 65000
  ip_address = var.cgw_onprem_ip
  type       = "ipsec.1"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-cgw-${local.suffix}" })
  )
}

##VPN GW

resource "aws_vpn_gateway" "vpn-gw" {
  count  = var.enabled ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-vpn-gw-${local.suffix}" })
  )
}

##VPN GW Route Propagation

resource "aws_vpn_gateway_route_propagation" "vpn-gw-route-propagation-pub" {
  count          = local.vpn-gw-route-propagation-pub
  vpn_gateway_id = aws_vpn_gateway.vpn-gw[0].id
  route_table_id = var.route_table_pub_id[count.index]
}

resource "aws_vpn_gateway_route_propagation" "vpn-gw-route-propagation-priv" {
  count          = local.vpn-gw-route-propagation-pub
  vpn_gateway_id = aws_vpn_gateway.vpn-gw[0].id
  route_table_id = var.route_table_priv_id[count.index]
}

##VPN Connection

resource "aws_vpn_connection" "sts-vpn" {
  count               = var.enabled ? 1 : 0
  vpn_gateway_id      = aws_vpn_gateway.vpn-gw[0].id
  customer_gateway_id = aws_customer_gateway.cgw[0].id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-sts-vpn-${local.suffix}" })
  )
}

##VPN Connection Route

resource "aws_vpn_connection_route" "sts-vpn-route" {
  for_each               = var.enabled ? toset(var.onprem_cidr_block) : []
  destination_cidr_block = each.key
  vpn_connection_id      = aws_vpn_connection.sts-vpn[0].id
}
