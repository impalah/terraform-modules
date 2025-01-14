output "app_runner_service_url" {
  description = "URL of the App Runner service"
  value       = aws_apprunner_service.app_service.service_url
}

output "vpc_connector_arn" {
  description = "ARN of the VPC Connector"
  value       = aws_apprunner_vpc_connector.app_vpc_connector.arn
}

output "security_group_id" {
  description = "ID of the Security Group created for App Runner"
  value       = aws_security_group.app_runner_sg.id
}

