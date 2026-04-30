# ---  Subnets  ---
variable "subnets" {
  default = {
    "subnetA" = {cidr_block = "192.168.0.0/26" , az = "us-west-2a", ip_publico = "true"}
    "subnetB" = {cidr_block = "192.168.0.64/26", az = "us-west-2a", ip_publico = "false"}
    "subnetC" = {cidr_block = "192.168.0.128/26", az = "us-west-2a", ip_publico = "true"}
  }
}

variable "instance_configurations" {
  default = {
    most_recent = "true", instance_type = "t3.micro", ami_code = ["099720109477"]
  }
}

#  Instancias  
variable "EC2_instances" {
    default = {
        "Bastion" = {subnet = "subnetA"}
        "Invasor" = {subnet = "subnetC"}
        "Server_1" = {subnet = "subnetB"}
        "Server_2" = {subnet = "subnetB"}
    }
}

