data "external" "task_arn" {
  program = ["bash", "-c", "aws ecs list-tasks --cluster ${aws_ecs_cluster.ecs_exec.name} --output json | jq -r '.taskArns[]' | jq -nR '{task_arn: input}'"]
}

output "execute_command" {
  value = startswith(upper(var.os_family), "LINUX") ? "aws ecs execute-command --region ${data.aws_region.current.name} --cluster ${aws_ecs_cluster.ecs_exec.name} --task ${data.external.task_arn.result.task_arn} --container ${var.container_name} --command /bin/bash --interactive" : "aws ecs execute-command --region ${data.aws_region.current.name} --cluster ${aws_ecs_cluster.ecs_exec.name} --task ${data.external.task_arn.result.task_arn} --container ${var.container_name} --command powershell.exe --interactive"
}
