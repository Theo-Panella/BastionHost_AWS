provider "aws" {
  region      = "us-west-2"
  profile     = "default"
}

data "aws_ami" "ubuntu"{
  most_recent = var.instance_configurations.most_recent
  owners = var.instance_configurations.ami_code
}

# --- Arquitetura de Rede --- 
resource "aws_vpc" "VPC1" {
  cidr_block = "192.168.0.0/28"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id = aws_vpc.VPC1.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
}

# --- Instancias ---
resource "aws_instance" "" {

}