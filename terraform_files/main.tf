provider "aws" {
  region      = "us-west-2"
  profile     = "default"
}

# ============= AMI =============
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

# ============= Network Components =============

# ============= VPC =============
resource "aws_vpc" "VPC1" {
  cidr_block = "192.168.0.0/24"
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC1.id

  tags = {
    Name = "main-igw"
  }
}

# ============= Subnets =============
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

# ============= Network Policy =============

# ============= ACLs =============
resource "aws_network_acl" "acl_subnets" {
  for_each = local.ACLs
  vpc_id = aws_vpc.VPC1.id                             
  subnet_ids = [aws_subnet.subnets[each.value.subnet_name].id]
  
  dynamic "egress" {
    for_each = each.value.egress
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }
}


# ============= Route Table =============
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.VPC1.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.VPC1.id
}

# ============= Route Table association =============
resource "aws_route_table_association" "public_association_subnet_global" {
  for_each = {
    for sub_a, sub_b in var.subnets : sub_a => sub_b if sub_b.ip_publico == "true"
  }
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.subnets[each.key].id
}

resource "aws_route_table_association" "private_association_subnet_global" {
  for_each = {
    for sub_a, sub_b in var.subnets : sub_a => sub_b if sub_b.ip_publico == "false"
  }
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.subnets[each.key].id
}

# ============= Instances =============

# ============= Security Groups =============
resource "aws_security_group" "sgs" {
  name = "Bastion-sg"
  vpc_id = aws_vpc.VPC1.id 

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============= Instances configs =============cccc
resource "aws_instance" "instances" {
  
  for_each = var.EC2_instances
  ami = data.aws_ami.linux.id
  instance_type = var.instance_configurations.instance_type
  subnet_id = aws_subnet.subnets[each.value.subnet].id
  vpc_security_group_ids = [aws_security_group.sgs.id]
  key_name = aws_key_pair.key_connection.key_name

  tags = {
    Name = each.key
  }
}

# ============= Chave SSH para conexão =============
resource "aws_key_pair" "key_connection" {
  key_name   = "key-subnetA"
  public_key = file(".ssh/terraform-key.pub")  # caminho da sua chave local
}
