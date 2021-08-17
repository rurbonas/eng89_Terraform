# IaC with Terraform

![](terra.png)

We'll build a script to connect to AWS and download/setup all dependencies
- keyword: `provider` allows us to connect to aws
- then we will run `terraform init`
- then we'll move on to launching aws services
- keyword: `resource` provide resource name
- resource aws_ec2_instance, name it as eng89_ron_terraform, ami, type of instance, with or without ip
- `terraform plan` to check syntax
- `terraform apply` to execute code

Create a `variable.tf` file
```
variable "AWS_KEY_NAME" 
	{ default = "eng89_ron_ter" }
variable "AWS_KEY_PATH" 
	{ default = "~/.ssh/eng89_ron_ter.pem" }
```
Edit `main.tf`
```
provider "aws" {
	
	region = "eu-west-1"
}

resource "aws_instance" "app_instance" {
	key_name = var.AWS_KEY_NAME
	ami = "ami-038d7b856fe7557b3"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	tags = {
		 Name = "eng89_ron_terraform"
	}
}
```

To create public/private keys in Git Bash
- Head over to your .ssh folder and create .pub and .pem keys
- `ssh-keygen -t rsa -b 2048 -v -f eng89_ron_ter`
- `mv eng89_ron_ter eng89_ron_ter.pem` to add the .pem extension
- `chmod 400 eng89_ron_ter.pem`
- `chmod 600 eng89_ron_ter.pub`

Import Public key to AWS
- Navigate to: EC2 >> Network & Security >> Key Pairs
- Actions >> Import key pair
- Name: `eng89_ron_ter`
- Browse and import the `eng89_ron_ter.pub` file
- Press `Import Key Pair` button

Now we can SSH into the newly created EC2 instance from our .ssh folder




More info on how to set-up Tables:
https://github.com/rurbonas/eng89_VPC_setup


### Final code
main.tf
```
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
  enable_dns_support = true
  enable_dns_hostnames = true

  
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
 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "eng89_ron_sg_app"
    }
}

# NETWORK ACLs
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id

  
  ingress {
      protocol   = "tcp"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 80
      to_port    = 80
    }



  ingress {
      protocol   = "tcp"
      rule_no    = 120
      action     = "allow"
      cidr_block = var.my_ip # MY IP
      from_port  = 22
      to_port    = 22
    }

  egress {
      protocol   = "tcp"
      rule_no    = 110
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 80
      to_port    = 80
    }

  egress {
      protocol   = "tcp"
      rule_no    = 120
      action     = "allow"
      cidr_block = "10.211.2.0/24"
      from_port  = 27017
      to_port    = 27017
    }



  tags = {
    Name = "eng89_ron_terra_nacl_pub"
  }
}

# launch an instance
resource "aws_instance" "app_instance" {
  ami = var.app_ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids = [aws_security_group.ssh-allowed.id]
  tags = {
      Name = var.name
  }
   #The key_name to ssh into instance
  key_name = var.aws_key_name
  # aws_key_path = var.aws_key_path

  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.aws_key_path)
      host        = self.public_ip
    }

  provisioner "remote-exec" {
	inline = [
	"cd app/",
	"npm start"
	]
  }
}
```

variable.tf
```
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
```
