# We'll build a script to connect to AWS and download/setup all dependencies
# keyword: `provider` allows us to connect to aws
provider "aws" {
	
	region = "eu-west-1"
}

# Let's create a VPC  
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block       = var.cidr_block 
  #"10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = var.vpc_name
  }
}

# Create Subnet
resource "aws_subnet" "prod-subnet-public-1" {
    vpc_id = aws_vpc.terraform_vpc_code_test.id
    cidr_block = "10.211.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-1a"
    tags = {
        Name = "eng89_ron_subnet_public"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  
  tags = {
    Name = var.igw_name
  }
}

#Create Custom Route Table
resource "aws_route_table" "prod-public-crt" {
    vpc_id = aws_vpc.terraform_vpc_code_test.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.terraform_igw.id
    }
    
    tags = {
        Name = "eng89_ron_rt"
    }
}

resource "aws_route_table_association" "prod-crta-public-subnet-1"{
    subnet_id = aws_subnet.prod-subnet-public-1.id
    route_table_id = aws_route_table.prod-public-crt.id
}

resource "aws_security_group" "ssh-allowed" {
    vpc_id = aws_vpc.terraform_vpc_code_test.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "eng89_ron_sg_app"
    }
}

# launch an instance
resource "aws_instance" "app_instance" {
  ami = var.app_ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
  tags = {
      Name = var.name
  }
   #The key_name to ssh into instance
  key_name = var.aws_key_name
  # aws_key_path = var.aws_key_path
}

# resource "aws_instance" "app_instance" {
# 	key_name = "eng89_ron_ter"
# 	ami = "ami-038d7b856fe7557b3"
# 	instance_type = "t2.micro"
# 	associate_public_ip_address = true
# 	tags = {
# 		 Name = "eng89_ron_terraform"
# 	}
# }
