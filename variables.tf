variable "cidr_vpc" {
    default = "10.0.0.0/16"
}

variable "cidr_sub1" {
    default = "10.0.0.0/24"
}

variable "az_sub1" {
    default = "us-east-1a"
}

variable "cidr_sub2" {
    default = "10.0.1.0/24"
}

variable "az_sub2" {
    default = "us-east-1b"
}

variable "mapPublicIPonlaunch" {
  default = "true"
}

variable "routeTableCIDR" {
  default = "0.0.0.0/0"
}

variable "bucketName" {
  default = "hardikgandhiterraformproject2024"
}

variable "ami" {
  default = "ami-04b70fa74e45c3917"
}

variable "instance_type" {
  default = "t2.micro"
}


