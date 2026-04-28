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
  cidr_block = "192.168.0.0/24"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id = aws_vpc.VPC1.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

# --- Instancias ----
resource "aws_instance" "instances" {
  
  for_each = var.EC2_instances
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_configurations.instance_type
  subnet_id = aws_subnet.subnets[each.value.subnet].id

  tags = {
    Name = each.key
  }
}
