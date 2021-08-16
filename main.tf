# We'll build a script to connect to AWS and download/setup all dependencies
# keyword: `provider` allows us to connect to aws
provider "aws" {
	
	region = "eu-west-1"
}

# then we will run `terraform init`
# then we'll move on to launching aws services

# keyword: `resource` provide resource name
# resource aws_ec2_instance, name it as eng89_ron_terraform, ami, type of instance, with or without ip
resource "aws_instance" "app_instance" {
	key_name = "eng89_ron_ter"
	ami = "ami-038d7b856fe7557b3"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	tags = {
		 Name = "eng89_ron_terraform"
	}
}


# terraform plan
# terraform apply