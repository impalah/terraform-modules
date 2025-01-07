output "aws_cognito_user_pool-userpool_id" {
  value = aws_cognito_user_pool.userpool.id
}

output "aws_cognito_user_pool-userpool_arn" {
  value = aws_cognito_user_pool.userpool.arn
}

output "aws_cognito_user_pool-admin_client_id" {
  value = aws_cognito_user_pool_client.api_client.id
}

output "aws_cognito_user_pool-admin_client_secret" {
  value = aws_cognito_user_pool_client.api_client.client_secret
}

output "aws_cognito_user_pool-user_client_id" {
  value = aws_cognito_user_pool_client.public_client.id
}

output "aws_cognito_user_pool-domain" {
  value = aws_cognito_user_pool_domain.cognito-domain.domain
}

output "url_base" {
  value = aws_cognito_user_pool.userpool.endpoint
}

