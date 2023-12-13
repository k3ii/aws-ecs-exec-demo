terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
