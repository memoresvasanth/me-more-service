variable "ecr_repo_name" {}
variable "ecs_cluster_name" {}
variable "ecs_task_family" {}
variable "ecs_task_execution_role_name" {}
variable "container_name" {}
variable "ecs_service_name" {}

resource "aws_ecr_repository" "repo" {
  name = var.ecr_repo_name
}

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

resource "aws_iam_role" "ecs_task_execution" {
  name = var.ecs_task_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_full_access" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.ecs_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = "${aws_ecr_repository.repo.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = true
  }
}