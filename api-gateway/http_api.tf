# ###################################################################################
# Step by step HTTP API gateway
# ###################################################################################

variable "create_lambda_permission" {
  description = "Flag to determine if lambda permission should be created"
  type        = bool
  default     = false
}

locals {
  create_lambda_permission = var.api_type == "HTTP" && var.function_name != ""
}

resource "aws_apigatewayv2_vpc_link" "apigw_vpc_link" {
  count = var.api_type == "HTTP" && length(var.vpc_subnets_ids) > 0 ? 1 : 0

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
  count = var.api_type == "HTTP" ? 1 : 0

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

# tODO: extend for diferent routes and integrations
resource "aws_apigatewayv2_integration" "apigw_integration" {
  count = var.api_type == "HTTP" ? 1 : 0

  api_id             = aws_apigatewayv2_api.api[count.index].id
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

  count = var.api_type == "HTTP" ? 1 : 0

  api_id             = aws_apigatewayv2_api.api[count.index].id

  # api_key_required   = false
  # authorization_type = "NONE"

  route_key = format("%s %s", var.route_method, var.route_path)
  target    = "integrations/${aws_apigatewayv2_integration.apigw_integration[count.index].id}"

  depends_on = [
    aws_apigatewayv2_integration.apigw_integration
  ]


}


# Integration permissions on lambda

resource "random_uuid" "lambda" {
  count = var.api_type == "HTTP" ? 1 : 0

}

resource "aws_lambda_permission" "apigw_lambda" {

  count = local.create_lambda_permission ? 1 : 0
  
  statement_id  = random_uuid.lambda[count.index].result
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("arn:aws:execute-api:%s:%s:%s/*/*%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, aws_apigatewayv2_api.api[count.index].id, var.route_path)
}



output "http_api_gateway_id" {
  value = var.api_type == "HTTP" ? aws_apigatewayv2_api.api[0].id : null
}

output "http_api_gateway_stage_message" {
  value = var.api_type == "HTTP" ? "aws [--profile my_profile] apigatewayv2 create-stage --region ${data.aws_region.current.name} --auto-deploy --api-id ${aws_apigatewayv2_api.api[0].id} --stage-name '$default'" : null
}

# Stage does not work using Terraform
# aws cli used instead

resource "aws_apigatewayv2_stage" "stage" {
  count = var.stage_name != null && var.api_type == "HTTP" ? 1 : 0

  name = var.stage_name

  # stage_variables {}
  api_id             = aws_apigatewayv2_api.api[count.index].id
  default_route_settings {
    logging_level            = "INFO"
    detailed_metrics_enabled = false
  }
  auto_deploy = true

  depends_on = [
    aws_apigatewayv2_route.apigw_route
  ]


  # # Bug in terraform-aws-provider with perpetual diff
  # lifecycle {
  #   ignore_changes = [deployment_id]
  # }

}





# resource "aws_apigatewayv2_deployment" "ApiGatewayV2Deployment" {
#   api_id      = aws_apigatewayv2_api.api.id
#   description = "Automatic deployment triggered by changes to the Api configuration"

#   depends_on = ["aws_apigatewayv2_route.apigw_route", "aws_apigatewayv2_integration.apigw_integration"]

# }







