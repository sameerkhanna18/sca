variable "aws_region" {
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "az" {
  default = "eu-west-2a"
}

variable "ubuntu_ami" {
  # Ubuntu 22.04 LTS for eu-west-2 (London)
  default = "ami-0a0ff88d0f3f85a14"
}
