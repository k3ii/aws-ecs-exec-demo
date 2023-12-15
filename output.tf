data "external" "task_arn" {
  program = ["bash", "-c", "aws ecs list-tasks --cluster ${aws_ecs_cluster.ecs_exec.name} --output json | jq -r '.taskArns[]' | jq -nR '{task_arn: input}'"]
}

#output "execute_command" {
#   value = "aws ecs execute-command --region ${data.aws_region.current.name} --cluster ${aws_ecs_cluster.ecs_exec.name} --task ${data.external.task_arn.result.task_arn} --container nginx --command /bin/bash --interactive"
#}

# Use a local value to store the data source result
locals {
  task_arns = data.external.task_arn.result
}

# Use a list constructor to create a list of execute-command commands
output "execute_command" {
  value = [for task_arn in local.task_arns : "aws ecs execute-command --region ${data.aws_region.current.name} --cluster ${aws_ecs_cluster.ecs_exec.name} --task ${task_arn} --container nginx --command /bin/bash --interactive"]
}

#It looks like you are trying to use a variable block to define a default value for your task_arns variable, but this is not allowed in Terraform. Variables cannot be assigned values from other resources or data sources, as they are meant to be inputs to your configuration, not outputs. You can find more information about this error in the Terraform documentation.
#To fix this error, you can either remove the variable block and use the data source result directly in your output, or use a local value to store the data source result and reference it in your output. For example, you could try something like this:
