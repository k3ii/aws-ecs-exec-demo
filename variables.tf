variable "log_group" {
  type = string
}

variable "subnet_public1_id" {
  type = string
}

variable "subnet_public2_id" {
  type = string
}

variable "s3_key_prefix" {
  type = string
}

variable "os_family" {
  type    = string
  default = "LINUX"
}

variable "task_definition_name" {
  type = string
}

variable "command" {
  type = string
}

variable "entryPoint" {
  type = string
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "cpu_arch" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "instance_count" {
  type = number
}
