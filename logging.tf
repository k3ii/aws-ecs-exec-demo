resource "random_string" "random" {
  length  = 10
  special = false
}

resource "aws_s3_bucket" "ecs_exec_output" {
  bucket = "ecs-exec-output-${lower(random_string.random.result)}"
  depends_on = [
    random_string.random
  ]
}

resource "aws_cloudwatch_log_group" "ecs_exec_output" {
  name = var.log_group
}

output "bucket_name" {
  value = aws_s3_bucket.ecs_exec_output.bucket
}
