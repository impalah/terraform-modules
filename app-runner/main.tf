# ###################################################################################
# Private VPC Connector for App Runner
# ###################################################################################

# Security group for the service
resource "aws_security_group" "app_runner_sg" {
  name        = "${var.app_name}-sg"
  description = "Security group for App Runner VPC Connector"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { "Name" = "${var.app_name}-sg" },
    var.tags,
    var.default_tags,
  )

}


# Create private endpoint for App Runner
resource "aws_vpc_endpoint" "private_vpc_endpoint" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.apprunner.requests"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.private_subnets
  private_dns_enabled = false

  # Custom Policy for Gateway or Interface Endpoints
  # policy = each.value.policy

  # Security groups for Interface Endpoints
  security_group_ids = [aws_security_group.app_runner_sg.id]

  tags = merge(
    { Name = "${var.app_name}-ep" },
    var.tags,
    var.default_tags,
  )
}



resource "aws_iam_role" "app_runner_access_role" {
  name = "${var.app_name}-app-runner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_access_policy_ecr" {
  role       = aws_iam_role.app_runner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# resource "aws_iam_role_policy" "app_runner_access_policy_custom" {
#   name = "app-runner-access-policy-custom"
#   role = aws_iam_role.app_runner_access_role.id

#   policy = var.access_role_policy

# }


resource "aws_iam_role" "app_runner_instance_role" {
  name = "${var.app_name}-app-runner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_instance_ecr_policy" {
  role       = aws_iam_role.app_runner_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role_policy_attachment" "app_runner_instance_ec2_policy" {
  role       = aws_iam_role.app_runner_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_role_policy" "app_runner_instance_policy" {
  name = "${var.app_name}-app-runner-instance-policy"
  role = aws_iam_role.app_runner_instance_role.id

  policy = var.instance_role_policy

}





resource "aws_apprunner_vpc_connector" "app_vpc_connector" {
  vpc_connector_name = "${var.app_name}-vpc-connector"
  subnets            = var.private_subnets
  security_groups    = [aws_security_group.app_runner_sg.id]

  tags = merge(
    { "Name" = "${var.app_name}-vpc-connector" },
    var.tags,
    var.default_tags,
  )

}

resource "aws_apprunner_service" "app_service" {
  service_name = var.app_name

  instance_configuration {
    instance_role_arn = aws_iam_role.app_runner_instance_role.arn
    cpu               = var.cpu
    memory            = var.memory
  }

  source_configuration {

    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_access_role.arn
    }

    image_repository {
      image_identifier      = var.ecr_image_uri
      image_repository_type = "ECR"

      image_configuration {
        port                          = var.port
        runtime_environment_variables = var.environment_variables
        start_command                 = var.start_command
      }


    }
    auto_deployments_enabled = var.auto_deployments_enabled
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.app_vpc_connector.arn
    }
    ingress_configuration {
      is_publicly_accessible = var.is_publicly_accessible
    }
  }

  health_check_configuration {
    path                = var.health_check_configuration.path
    protocol            = var.health_check_configuration.protocol
    interval            = var.health_check_configuration.interval
    timeout             = var.health_check_configuration.timeout
    healthy_threshold   = var.health_check_configuration.healthy_threshold
    unhealthy_threshold = var.health_check_configuration.unhealthy_threshold
  }

  tags = merge(
    { "Name" = var.app_name },
    var.tags,
    var.default_tags,
  )
}


# Create VPC Ingress Connection
resource "aws_apprunner_vpc_ingress_connection" "private_vpc_connection" {
  name        = "${var.app_name}-privatevpc-connection"
  service_arn = aws_apprunner_service.app_service.arn

  ingress_vpc_configuration {
    vpc_id          = var.vpc_id
    vpc_endpoint_id = aws_vpc_endpoint.private_vpc_endpoint.id
  }

  tags = merge(
    { "Name" = "${var.app_name}-privatevpc-connection" },
    var.tags,
    var.default_tags,
  )
}

output "domain_name" {
  description = "Domain name of the App Runner service"
  value       = aws_apprunner_vpc_ingress_connection.private_vpc_connection.domain_name
}

