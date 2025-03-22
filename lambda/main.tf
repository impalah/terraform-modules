################################################################################
# Role and policy configurations
################################################################################

resource "aws_iam_role" "lambda_exec_role" {
  name               = format("%s-lambda_exec_role", var.function_name)
  assume_role_policy = coalesce(var.assume_role_policy, file("${path.module}/policies/lambda-role-policy.json"))
}

resource "aws_iam_role_policy" "lambda_exec_role_policy" {
  name   = format("%s-lambda_exec_policy", var.function_name)
  role   = aws_iam_role.lambda_exec_role.id
  policy = var.exec_role_policy
}

resource "aws_security_group" "lambda_sg" {

  count = var.vpc_id != null ? 1 : 0

  name        = format("%s-lambda_sg", var.function_name)
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      # TODO: only allow from the load balancer
      # security_groups = [
      #   "${aws_security_group.ServiceLBSecurityGroup.id}"
      # ]
      description = format("Allow from anyone on port %d", ingress.value)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Lambda function from ECR image
resource "aws_lambda_function" "lambda_function" {

  architectures = var.function_architectures

  dynamic "environment" {
    for_each = length(var.env_variables) > 0 ? [var.env_variables] : []
    content {
      variables = environment.value
    }
  }

  ephemeral_storage {
    size = var.function_storage
  }

  function_name                  = var.function_name
  image_uri                      = var.image
  memory_size                    = var.function_memory
  package_type                   = "Image"
  reserved_concurrent_executions = "-1"
  role                           = aws_iam_role.lambda_exec_role.arn
  skip_destroy                   = "false"
  timeout                        = var.function_timeout

  tracing_config {
    mode = "PassThrough"
  }

  image_config {
    command           = var.image_config.command
    entry_point       = var.image_config.entry_point
    working_directory = var.image_config.working_directory
  }

  dynamic "vpc_config" {
    for_each = var.vpc_id != null ? [var.vpc_id] : []
    content {
      subnet_ids         = var.vpc_subnets_ids
      security_group_ids = [aws_security_group.lambda_sg[0].id]
    }
  }

  tags = merge(
    { "Name" = var.function_name },
    var.tags,
    var.default_tags,
  )

}

# Cloudwatch log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 14
}


output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "function_arn" {
  value = aws_lambda_function.lambda_function.arn
}
