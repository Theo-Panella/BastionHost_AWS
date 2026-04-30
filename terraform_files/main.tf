provider "aws" {
  region      = "us-west-2"
  profile     = "default"
}

data "aws_ami" "linux"{
  most_recent = var.instance_configurations.most_recent
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]  # Amazon Linux 2023
  }

    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

# --- Componentes da Rede --- 
resource "aws_vpc" "VPC1" {
  cidr_block = "192.168.0.0/24"
  instance_tenancy = "default"
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id = aws_vpc.VPC1.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.az
  map_public_ip_on_launch = each.value.ip_publico

  tags = {
    Name = each.key
  }
}

# --- Politicas da Rede ---

# --- ACLs ---
resource "aws_network_acl" "acl_subnets" {
  vpc_id = aws_vpc.VPC1.id
  
  egress = {
    protocol = "",
    rule_no = 1
    action = "allow"
    cidr_block = ""
    from_port = 22
    to_port = 22
  }

  ingress = {
    protocol = "",
    rule_no = 1
    action = "allow"
    cidr_block = ""
    from_port = 22
    to_port = 22
  }
}


# --- Instancias ----
resource "aws_instance" "instances" {
  
  for_each = var.EC2_instances
  ami = data.aws_ami.linux.id
  instance_type = var.instance_configurations.instance_type
  subnet_id = aws_subnet.subnets[each.value.subnet].id
  key_name = aws_key_pair.key_connection.key_name

  tags = {
    Name = each.key
  }
}

# Chave SSH para conexão
resource "aws_key_pair" "key_connection" {
  key_name   = "key-subnetA"
  public_key = file(".ssh/key_terraform.pub")  # caminho da sua chave local
}
