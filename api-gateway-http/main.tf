# ###################################################################################
# Step by step API gateway
# ###################################################################################



resource "aws_apigatewayv2_vpc_link" "apigw_vpc_link" {

  count = length(var.vpc_subnets_ids) > 0 ? 1 : 0

  name               = format("%s-http-vpc-link", var.api_name)
  security_group_ids = []
  subnet_ids         = var.vpc_subnets_ids

  tags = merge(
    { "Name" = format("%s-http-vpc-link", var.api_name) },
    var.tags,
    var.default_tags,
  )

}

resource "aws_apigatewayv2_api" "api" {

  protocol_type = var.protocol_type

  # TODO: for websockets
  # api_key_selection_expression = "$request.header.x-api-key"
  # route_selection_expression   = "$request.method $request.path"

  name = format("%s-http-api", var.api_name)

  tags = merge(
    { "Name" = format("%s-http-vpc-link", var.api_name) },
    var.tags,
    var.default_tags,
  )

}


resource "aws_apigatewayv2_integration" "apigw_integration" {

  api_id             = aws_apigatewayv2_api.api.id
  description        = format("%s Integration", var.integration_type)

  integration_type   = var.integration_type
  integration_uri    = var.integration_uri
  integration_method = var.integration_method
  payload_format_version = var.payload_format_version

  # Integration through VPC Link
  # connection_id      = aws_apigatewayv2_vpc_link.apigw_vpc_link.id
  # connection_type    = "VPC_LINK"

  timeout_milliseconds   = var.timeout_milliseconds

  depends_on = [
    aws_apigatewayv2_api.api
  ]


}


resource "aws_apigatewayv2_route" "apigw_route" {

  api_id = aws_apigatewayv2_api.api.id

  # api_key_required   = false
  # authorization_type = "NONE"

  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"

  depends_on = [
    aws_apigatewayv2_integration.apigw_integration
  ]


}

# Stage does not work using Terraform
# aws cli used instead

# resource "aws_apigatewayv2_stage" "ApiGatewayV2Stage" {
#   name = "$default"
#   # stage_variables {}
#   api_id = aws_apigatewayv2_api.api.id
#   default_route_settings {
#     logging_level            = "INFO"
#     detailed_metrics_enabled = false
#   }
#   auto_deploy = true
#   tags        = var.tags

#   depends_on = [
#     aws_apigatewayv2_route.apigw_route
#   ]


#   # Bug in terraform-aws-provider with perpetual diff
#   lifecycle {
#     ignore_changes = [deployment_id]
#   }

# }





# resource "aws_apigatewayv2_deployment" "ApiGatewayV2Deployment" {
#   api_id      = aws_apigatewayv2_api.api.id
#   description = "Automatic deployment triggered by changes to the Api configuration"

#   depends_on = ["aws_apigatewayv2_route.apigw_route", "aws_apigatewayv2_integration.apigw_integration"]

# }







