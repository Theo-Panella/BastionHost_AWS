# ---  Subnets  ---
variable "subnets" {
  default = {
    "subnetA" = {cidr_block = "192.168.0.0/26" , az = "us-west-2"}
    "subnetB" = {cidr_block = "192.168.0.64/26", az = "us-west-2"}
    "subnetC" = {cidr_block = "192.168.0.128/26", az = "us-west-2"}
  }
}



# ---  Instancias  ---
variable "instance_type" {
    type = string
    description = "Instance type for Bastion-Host"
}

variable "Bastion" {
  
}