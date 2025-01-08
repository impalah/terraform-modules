output "userpool_id" {
  value = aws_cognito_user_pool.userpool.id
}

output "userpool_arn" {
  value = aws_cognito_user_pool.userpool.arn
}

output "domain" {
  value = aws_cognito_user_pool_domain.cognito-domain.domain
}

output "url_base" {
  value = aws_cognito_user_pool.userpool.endpoint
}

