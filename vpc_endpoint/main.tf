
resource "aws_vpc_endpoint" "this" {
  for_each       = { for idx, ep in var.endpoints : idx => ep }
  vpc_id         = var.vpc_id
  service_name   = each.value.service_name
  vpc_endpoint_type = each.value.type

  # Subnets for Interface Endpoints
  subnet_ids = each.value.type == "Interface" ? var.subnet_ids : null

  # Route tables for Gateway Endpoints
  route_table_ids = each.value.type == "Gateway" ? each.value.route_table_ids : null

  # Private DNS for Interface Endpoints
  private_dns_enabled = each.value.type == "Interface" ? lookup(each.value, "private_dns", true) : null

  # Custom Policy for Gateway or Interface Endpoints
  policy = each.value.policy

  # Security groups for Interface Endpoints
  security_group_ids = each.value.type == "Interface" ? each.value.security_groups : null

  tags = merge(
    { "Name" = var.vpc_name },
    var.tags,
    var.default_tags,
  )
}