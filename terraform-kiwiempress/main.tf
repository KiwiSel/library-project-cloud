terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "kiwiempress"
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_security_group" "app" {
  name        = "library-app-security-group"
  description = "Security group for library ECS application"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP traffic to FastAPI"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "rds" {
  name        = "library-rds-security-group"
  description = "Security group for library PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Allow PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "library" {
  identifier = "library-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "library_db"
  username = "library_user"
  password = var.db_password

  port = 5432

  publicly_accessible = false

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "library-postgres"
  }
}


resource "aws_ecr_repository" "library" {
  name = "library-api"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "library-api"
  }
}


resource "aws_ecs_cluster" "library" {
  name = "library-cluster"

  tags = {
    Name = "library-cluster"
  }
}



resource "aws_iam_role" "ecs_execution" {
  name = "library-ecs-execution-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_cloudwatch_log_group" "library" {
  name = "/ecs/library-api"

  retention_in_days = 7
}



resource "aws_ecs_task_definition" "library" {
  family = "library-api"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name = "library-api"

      image = "${aws_ecr_repository.library.repository_url}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "POSTGRES_DB"
          value = "library_db"
        },
        {
          name  = "POSTGRES_USER"
          value = "library_user"
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = var.db_password
        },
        {
          name  = "POSTGRES_HOST"
          value = aws_db_instance.library.address
        },
        {
          name  = "POSTGRES_PORT"
          value = "5432"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.library.name
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "library"
        }
      }
    }
  ])

  tags = {
    Name = "library-api-task"
  }
}


# --------------------------------------------------
# ECS service
# --------------------------------------------------

resource "aws_ecs_service" "library" {
  name = "library-api"

  cluster = aws_ecs_cluster.library.id

  task_definition = aws_ecs_task_definition.library.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.default.ids

    security_groups = [
      aws_security_group.app.id
    ]

    assign_public_ip = true
  }

  tags = {
    Name = "library-api-service"
  }
}