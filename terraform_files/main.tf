provider "aws" {
  region      = "us-west-2"
  profile     = "default"
}

# ======================= AMI EC2 =======================
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

# ======================= NETWORK COMPONENTS =======================
resource "aws_vpc" "VPC1" {
  cidr_block = "192.168.0.0/24"
  instance_tenancy = "default"
}

# ======================= INTERNET GATEWAY =======================
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC1.id

  tags = {
    Name = "main-igw"
  }
}

# ======================= SUBNETS =======================
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

# ======================= NETWORK POLICY =======================
# ======================= ACLS =======================
resource "aws_network_acl" "acl_subnetA" {
  vpc_id = aws_vpc.VPC1.id                             
  subnet_ids = [aws_subnet.subnets["subnetA"].id]           

  egress {                                                   
    protocol = "tcp"                                      
    rule_no = 1
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  }

  ingress {                                                  
    protocol = "tcp"
    rule_no = 2
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  }

  tags = {
    Name = "ACL da Subnet A"
  }
}

resource "aws_network_acl" "acl_subnetB" {
  vpc_id = aws_vpc.VPC1.id                             
  subnet_ids = [aws_subnet.subnets["subnetB"].id]           

  egress {                                                   
    protocol = "tcp"                                      
    rule_no = 1
    action = "allow"
    cidr_block = aws_subnet.subnets["subnetA"].cidr_block
    from_port = 22
    to_port = 22
  }

  ingress {                                                  
    protocol = "tcp"
    rule_no = 2
    action = "allow"
    cidr_block = aws_subnet.subnets["subnetA"].cidr_block
    from_port = 22
    to_port = 22
  }

  tags = {
    Name = "ACL da Subnet B"
  }
}

resource "aws_network_acl" "acl_subnetC" {
  vpc_id = aws_vpc.VPC1.id                             
  subnet_ids = [aws_subnet.subnets["subnetC"].id]           

  egress {                                                   
    protocol = "tcp"                                      
    rule_no = 1
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  }

  ingress {                                                  
    protocol = "tcp"
    rule_no = 2
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    to_port = 22
  }

  tags = {
    Name = "ACL da Subnet C"
  }
}

# ======================= ROUTE TABLE =======================
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.VPC1.id
  
  route {
    cidr_block = aws_subnet.subnets["subnetA"].cidr_block
    gateway_id = aws_internet_gateway.gw.id
  }
}

# ======================= INSTANCES =======================
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

# ======================= SSH KEY =======================
resource "aws_key_pair" "key_connection" {
  key_name   = "key-subnetA"
  public_key = file(".ssh/key_terraform.pub")  # caminho da sua chave local
}
