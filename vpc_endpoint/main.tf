
resource "aws_vpc_endpoint" "this" {
  for_each = { for idx, ep in var.endpoints : idx => ep }

  vpc_id       = var.vpc_id
  service_name = each.value.service_name
  vpc_endpoint_type = each.value.type

  dynamic "subnet_ids" {
    for_each = each.value.type == "Interface" ? [1] : []
    content {
      value = var.subnet_ids
    }
  }

  dynamic "route_table_ids" {
    for_each = each.value.type == "Gateway" ? [1] : []
    content {
      value = each.value.route_table_ids
    }
  }

  private_dns_enabled = lookup(each.value, "private_dns", false)

  dynamic "policy" {
    for_each = each.value.policy != null ? [1] : []
    content {
      value = each.value.policy
    }
  }

  tags = {
    Name = each.value.name
  }

  dynamic "security_group_ids" {
    for_each = each.value.type == "Interface" && length(each.value.security_groups) > 0 ? [1] : []
    content {
      value = each.value.security_groups
    }
  }
}
