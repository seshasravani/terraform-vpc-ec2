variable "key_name" {
  default = "instance"
  description = "the ssh key to use in the EC2 machines"
}

variable "vpc-fullcidr" {
    default = "172.28.0.0/16"
  description = "the vpc cdir"
}

variable "Subnet-Public-Project1-CIDR" {
  default = "172.28.0.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Private-Project1-CIDR" {
  default = "172.28.3.0/24"
  description = "the cidr of the subnet"
}



