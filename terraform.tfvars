subnet_public1_id = "subnet-0c7700532762309bd"
subnet_public2_id = "subnet-04302b8e58b44baa6"
log_group         = "/aws/ecs/ecs-exec-demo"
s3_key_prefix     = "ecs-exec"

task_definition_name = "ecs_exec"
task_cpu             = "256"
task_memory          = "512"
cpu_arch             = "X86_64"
container_name       = "nginx"
container_image      = "nginx"
cluster_name         = "ecs-exec-cluster"
service_name         = "ecs-exec"
instance_count       = 1

