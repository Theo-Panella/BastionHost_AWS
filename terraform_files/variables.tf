variable "subnetA" {
    type = string
    description = "SubnetA para bastion host"
    default = "192.168.0.0/26"
}

variable "subnetB" {
    type = string
    description = "SubnetB de simulação de intrusão"
    default = "192.168.0.64/26"
}
