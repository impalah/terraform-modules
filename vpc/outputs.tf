output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = { for key, subnet in aws_subnet.private-subnet : key => subnet.id }
}

output "private_subnet_azs" {
  description = "AZs of the private subnets"
  value       = { for key, subnet in aws_subnet.private-subnet : key => subnet.availability_zone }
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = { for key, subnet in aws_subnet.public-subnet : key => subnet.id }
}

output "public_subnet_azs" {
  description = "AZs of the public subnets"
  value       = { for key, subnet in aws_subnet.public-subnet : key => subnet.availability_zone }
}

output "private_route_tables" {
  description = "IDs of the created private route tables"
  value       = values({ for rt in aws_route_table.private-subnet-route-table : rt.id })
}

output "public_route_tables" {
  description = "IDs of the created public route tables"
  value       = values({ for rt in aws_route_table.public-subnet-route-table : rt.id })
}

