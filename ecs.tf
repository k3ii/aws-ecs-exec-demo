locals {
  linux_parameters = startswith(upper(var.os_family), "LINUX") ? {
    "initProcessEnabled" : true
  } : {}
}

locals {
  container_definition = {
    name       = var.container_name,
    image      = var.container_image,
    command    = split(" ", var.command)
    entryPoint = split(" ", var.entryPoint)
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = var.log_group,
        "awslogs-region"        = data.aws_region.current.name,
        "awslogs-stream-prefix" = "container-stdout"
      }
    },
    linuxParameters = startswith(upper(var.os_family), "LINUX") ? local.linux_parameters : null,
  }
}

resource "aws_ecs_cluster" "ecs_exec" {
  name = var.cluster_name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs_exec.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec_output.name
        s3_bucket_name             = aws_s3_bucket.ecs_exec_output.bucket
        s3_key_prefix              = var.s3_key_prefix
      }
    }
  }
  depends_on = [
    aws_ecs_task_definition.ecs_exec
  ]
}

resource "aws_ecs_task_definition" "ecs_exec" {
  family                   = var.task_definition_name
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_exec_demo_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_exec_demo_task_role.arn
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  runtime_platform {
    operating_system_family = var.os_family
    cpu_architecture        = var.cpu_arch
  }
  container_definitions = jsonencode([local.container_definition])
}

resource "aws_ecs_service" "ecs_exec" {
  name                   = var.service_name
  cluster                = aws_ecs_cluster.ecs_exec.id
  task_definition        = aws_ecs_task_definition.ecs_exec.arn
  desired_count          = var.instance_count
  enable_execute_command = "true"
  launch_type            = "FARGATE"
  network_configuration {
    subnets = [
      data.aws_subnet.public1.id,
      data.aws_subnet.public2.id,
    ]
    security_groups = [
      aws_security_group.ecs_exec.id
    ]
    assign_public_ip = "true"
  }
  depends_on = [
    aws_ecs_task_definition.ecs_exec,
    aws_ecs_cluster.ecs_exec,
  ]
}
