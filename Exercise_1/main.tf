# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region     = "eu-central-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "udacity_t2" {
  ami           = "ami-0233214e13e500f77"
  instance_type = "t2.micro"
  subnet_id = "subnet-05662cf095f3128cc"

  tags = {
    Name = "Udacity T2"
  }

  count = 4
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "udacity_m4" {
  ami           = "ami-0233214e13e500f77"
  instance_type = "m4.large"
  subnet_id = "subnet-05662cf095f3128cc"

  tags = {
    Name = "Udacity M4"
  }

  count = 2
}