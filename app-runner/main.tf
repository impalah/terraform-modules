# ###################################################################################
# Step by step App Runner
# ###################################################################################


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

  source_configuration {
    image_repository {
      image_identifier      = var.ecr_image_uri
      image_repository_type = "ECR"

      image_configuration {
        runtime_environment_variables = var.environment_variables
        start_command                 = var.start_command
      }
    }
    auto_deployments_enabled = true
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.app_vpc_connector.arn
    }
  }

  tags = merge(
    { "Name" = var.app_name },
    var.tags,
    var.default_tags,
  )
}

