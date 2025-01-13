# # ###################################################################################
# # Step by step REST API gateway
# # ###################################################################################



# resource "aws_api_gateway_rest_api" "api" {
#   count = var.api_type == "REST" ? 1 : 0

#   protocol_type = var.protocol_type

#   # TODO: for websockets
#   # api_key_selection_expression = "$request.header.x-api-key"
#   # route_selection_expression   = "$request.method $request.path"

#   name = format("%s-rest-api", var.api_name)

#   tags = merge(
#     { "Name" = format("%s-rest-api", var.api_name) },
#     var.tags,
#     var.default_tags,
#   )


# }

# resource "aws_api_gateway_resource" "root" {
#   count = var.api_type == "REST" ? 1 : 0

#   rest_api_id = aws_api_gateway_rest_api.api[count.index].id
#   parent_id   = aws_api_gateway_rest_api.api[count.index].root_resource_id
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "proxy_method" {
#   count = var.api_type == "REST" ? 1 : 0

#   rest_api_id   = aws_api_gateway_rest_api.api[count.index].id
#   resource_id   = aws_api_gateway_resource.root[count.index].id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "proxy_integration" {
#   count = var.api_type == "REST" ? 1 : 0

#   rest_api_id             = aws_api_gateway_rest_api.api[count.index].id
#   resource_id             = aws_api_gateway_resource.root[count.index].id
#   http_method             = aws_api_gateway_method.proxy_method[count.index].http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = var.lambda_function_name
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   count = var.api_type == "REST" ? 1 : 0

#   depends_on = [aws_api_gateway_integration.proxy_integration]
#   rest_api_id = aws_api_gateway_rest_api.api[count.index].id
#   stage_name  = var.stage_name
# }

# resource "aws_lambda_permission" "api_gateway_permission" {
#   count = var.api_type == "REST" ? 1 : 0

#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = var.lambda_function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api[count.index].execution_arn}/*"
# }

# output "rest_api_gateway_url" {
#   description = "The invoke URL of the API Gateway"
#   value       = var.api_type == "REST" ? aws_api_gateway_deployment.deployment.invoke_url : null
# }
