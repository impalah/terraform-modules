output "api_gateway_id" {
  value = aws_apigatewayv2_api.api.id
}

output "api_gateway_stage_message" {
  value = "aws [--profile my_profile] apigatewayv2 create-stage --region ${data.aws_region.current.name} --auto-deploy --api-id ${aws_apigatewayv2_api.api.id} --stage-name '$default'"
}

data "aws_region" "current" {}
