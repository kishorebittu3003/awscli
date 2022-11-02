variable "region" {
    type = string
    default = "us-west-2"
  
}

variable "vpc_cidrblock" {
    type = string
    default = "192.168.0.0/16"
  
}

variable "sub_cidr" {
    type = string
    default = "192.168.0.0/24"
  
}

variable "az_zones" {
  type = string
    
  
}

variable "ami_id" {
    type = string
    
  
}


variable "instancetype" {
    type = string
    default = "t2.micro"
  
}
variable "key_name" {
    type = string
    default = "key"
  
}

