# Let's creatge a variable to apply DRY

variable "name" {
  default="eng89_ron_terraform_app"
}

variable "app_ami_id" {
  default="ami-0c0b30eded2ee2098"
}

variable "vpc_id" {

  default = "vpc-0c16e4c23eb11deed"
}
variable "vpc_name" {
  default = "Eng89_ron_terraform_vpc"
}
variable "cidr_block" {
  default="10.211.0.0/16"
}
variable "igw_name" {
  default = "Eng89_ron_terraform_igw"
}

variable "aws_key_name" {

  default = "eng89_ron_ter"
}

variable "aws_key_path" {

  default = "~/.ssh/eng89_ron_ter.pem"
}
variable "my_ip" {
  default="89.238.141.230/32"
}
