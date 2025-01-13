# ###################################################################################
# Step by step HTTP API gateway
# ###################################################################################

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
    { "Name" = format("%s-http-api", var.api_name) },
    var.tags,
    var.default_tags,
  )

}

# tODO: extend for diferent routes and integrations
resource "aws_apigatewayv2_integration" "apigw_integration" {
  count = var.api_type == "HTTP" ? 1 : 0

  api_id      = aws_apigatewayv2_api.api[count.index].id
  description = format("%s Integration", var.integration_type)

  integration_type       = var.integration_type
  integration_uri        = var.integration_uri
  integration_method     = var.integration_method
  payload_format_version = var.payload_format_version

  # Integration through VPC Link
  # connection_id      = aws_apigatewayv2_vpc_link.apigw_vpc_link.id
  # connection_type    = "VPC_LINK"

  timeout_milliseconds = var.timeout_milliseconds

  depends_on = [
    aws_apigatewayv2_api.api
  ]


}


resource "aws_apigatewayv2_route" "apigw_route" {

  count = var.api_type == "HTTP" ? 1 : 0

  api_id = aws_apigatewayv2_api.api[count.index].id

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

  count = var.api_type == "HTTP" && var.integration_service == "LAMBDA" ? 1 : 0

  statement_id  = random_uuid.lambda[count.index].result
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("arn:aws:execute-api:%s:%s:%s/*/*%s", data.aws_region.current.name, data.aws_caller_identity.current.account_id, aws_apigatewayv2_api.api[count.index].id, var.route_path)

  depends_on = [
    aws_apigatewayv2_integration.apigw_integration
  ]

}



output "http_api_gateway_id" {
  value = var.api_type == "HTTP" ? aws_apigatewayv2_api.api[0].id : null
}

output "http_api_gateway_stage_message" {
  value = var.api_type == "HTTP" ? "aws [--profile my_profile] apigatewayv2 create-stage --region ${data.aws_region.current.name} --auto-deploy --api-id ${aws_apigatewayv2_api.api[0].id} --stage-name '$default'" : null
}



resource "aws_iam_role" "api_gateway_cloudwatch_logs" {
  name = "api-gateway-cloudwatch-logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_logs" {
  role       = aws_iam_role.api_gateway_cloudwatch_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_logs.arn
}

resource "aws_cloudwatch_log_group" "api_gateway_logs_api" {
  # TODO: make configurable
  name              = format("/aws/apigateway/%s", var.api_name)
  retention_in_days = 7
}


resource "aws_apigatewayv2_stage" "stage" {

  count       = var.api_type == "HTTP" ? 1 : 0
  name        = var.stage_name
  auto_deploy = var.stage_autodeploy
  api_id      = aws_apigatewayv2_api.api[count.index].id

  # stage_variables {}
  # TODO: add default route settings
  default_route_settings {
    # logging_level            = "INFO"
    # detailed_metrics_enabled = false
    throttling_burst_limit = 10
    throttling_rate_limit  = 10
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs_api.arn
    format = jsonencode({
      authorizerError           = "$context.authorizer.error",
      identitySourceIP          = "$context.identity.sourceIp",
      integrationError          = "$context.integration.error",
      integrationErrorMessage   = "$context.integration.errorMessage"
      integrationLatency        = "$context.integration.latency",
      integrationRequestId      = "$context.integration.requestId",
      integrationStatus         = "$context.integration.integrationStatus",
      integrationStatusCode     = "$context.integration.status",
      requestErrorMessage       = "$context.error.message",
      requestErrorMessageString = "$context.error.messageString",
      requestId                 = "$context.requestId",
      routeKey                  = "$context.routeKey",
    })
  }

  depends_on = [
    aws_apigatewayv2_route.apigw_route
  ]


}





# resource "aws_apigatewayv2_deployment" "ApiGatewayV2Deployment" {
#   api_id      = aws_apigatewayv2_api.api.id
#   description = "Automatic deployment triggered by changes to the Api configuration"

#   depends_on = ["aws_apigatewayv2_route.apigw_route", "aws_apigatewayv2_integration.apigw_integration"]

# }







