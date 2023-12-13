resource "aws_ecs_cluster" "ecs_exec" {
  name = "ecs-exec-cluster"

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
  family                   = "ecs-exec"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_exec_demo_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_exec_demo_task_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = <<TASK_DEFINITION
    [
    {"name": "nginx",
            "image": "nginx",
            "linuxParameters": {
                "initProcessEnabled": true
            },            
            "logConfiguration": {
                "logDriver": "awslogs",
                    "options": {
                       "awslogs-group": "/aws/ecs/ecs-exec-demo",
                       "awslogs-region": "us-east-1",
                       "awslogs-stream-prefix": "container-stdout"
                    }
        }
    }
    ]
TASK_DEFINITION
}

resource "aws_ecs_service" "ecs_exec" {
  name                   = "ecs-exec"
  cluster                = aws_ecs_cluster.ecs_exec.id
  task_definition        = aws_ecs_task_definition.ecs_exec.arn
  desired_count          = 3
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
