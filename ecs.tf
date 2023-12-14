locals {
  empty = {}
  initProcessEnabled = {
  "initProcessEnabled": true
  }
}

locals {
  empty_json = jsonencode(local.empty)
  initProcessEnabled_json = jsonencode(local.initProcessEnabled)
}

locals {
  os_family = upper(var.os_family)
  LinuxParameters = startswith(local.os_family, "LINUX") ? local.initProcessEnabled_json : local.empty_json
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
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  runtime_platform {
    operating_system_family = local.os_family
    cpu_architecture        = var.cpu_arch
  }
  container_definitions = <<TASK_DEFINITION
    [
    {"name": "${var.container_name}",
     "image": "${var.container_image}",
     "linuxParameters": ${local.LinuxParameters},
     "logConfiguration": {
         "logDriver": "awslogs",
             "options": {
                "awslogs-group": "${var.log_group}",
                "awslogs-region": "${data.aws_region.current.name}",
                "awslogs-stream-prefix": "container-stdout"
             }
        }
    }
    ]
TASK_DEFINITION
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
