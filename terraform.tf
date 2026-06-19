terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
  required_version = ">= 1.2"
  
  backend "s3" {
    bucket         = "meu-bucket-tfstate"
    key            = "bastionhost/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
  }

}
