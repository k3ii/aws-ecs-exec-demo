resource "aws_default_vpc" "default" {}

data "aws_subnet" "public1" {
  id = var.subnet_public1_id
}

data "aws_subnet" "public2" {
  id = var.subnet_public2_id
}

data "http" "my_ip" {
  url = "https://ipconfig.io"
}

resource "aws_security_group" "ecs_exec" {
  name   = "ecs-exec"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
