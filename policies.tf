data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_kms_key" "ecs_exec" {}

data "aws_iam_policy_document" "ecs_tasks_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_role_policy" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:${var.log_group}:*",
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ecs_exec_output.bucket}/*",
    ]
  }
  statement {
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.ecs_exec_output.bucket}",
    ]
  }
  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      "${aws_kms_key.ecs_exec.arn}",
    ]
  }
}

data "aws_iam_policy" "ECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_tasks_role_policy" {
  name   = "ecs-tasks-trust-policy"
  policy = data.aws_iam_policy_document.ecs_tasks_role_policy.json
}

resource "aws_iam_role" "ecs_exec_demo_task_execution_role" {
  name               = "ecs-exec-demo-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust_policy.json
}

resource "aws_iam_role" "ecs_exec_demo_task_role" {
  name               = "ecs-exec-demo-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.ecs_exec_demo_task_execution_role.name
  policy_arn = data.aws_iam_policy.ECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role_policy_attachment" "task_role" {
  role       = aws_iam_role.ecs_exec_demo_task_role.name
  policy_arn = aws_iam_policy.ecs_tasks_role_policy.arn
}
