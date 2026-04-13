provider "aws" {
  region      = "us-west-2"
  profile     = "default"
}

resource "aws_vpc" "VPC1" {
  cidr_block = "192.168.0.0/26"

  tags = {
    name = "VPC1"
  }
}

resource "aws_subnet" "subnetA" {
  vpc_id = aws_vpc.VPC1.id
  subnet_id = var.subnet_id

}

