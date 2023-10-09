terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    /*time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }*/
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }

}
provider "aws" {
  region = "us-east-1"
}