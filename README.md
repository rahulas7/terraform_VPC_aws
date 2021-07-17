# Creating VPC using Terraform
## Description
Terraform is an infrastructure as code (IaC) tool that allows you to build, change infrastructure safely and efficiently.Terraform supports a number of cloud infrastructure providers such as Amazon Web Services, Microsoft Azure, IBM Cloud, Google Cloud Platform,VMware and OpenStack.
Here I have created a document on how to create a VPC along with 3 public/private subnets and network gateway for vpc. we will be making the following services, 3 public/private subnets, 1 nat gateway for private network to communicating outside the world, 2 route table , 1 network gateway and 1 elastic ip. you can create this vpc on any region making the changes in the tfvars file.

## Features

- Each subnet CIDR block created automatically using cidrsubnet Function on Terraform.
- We can create vpc on any region by changing values through vpc.tfvars and the source code is automatically applied, using values from tfvars and we do not need to edit the whole source code.



### Prerequisites
- IAM user access with attached policies for the creation of VPC.
- knoweldge in aws infrastructure
- Create a dedicated directory where you can create terraform configuration files.

### Installation
Please download Terraform the proper package for your operating system and architecture from terraform [repo](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

Steps to install terraform
```sh
wget https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_linux_amd64.zip
unzip terraform_1.0.2_linux_amd64.zip 
ls -l
-rwxr-xr-x  1 root root 80702567 Jul  7 17:43 terraform
-rw-r--r--  1 root root 33040495 Jul  7 18:08 terraform_1.0.2_linux_amd64.zip
mv terraform /usr/bin/
which terraform 
/usr/bin/terraform
```

here I am creating a directory to run the vpc project.
#mkdir vpc
#cd vpc
create a variable file to declare the values and then the tfvars file values can be passed through this variable file.

### Create a variables.tf file
```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "vpc_cidr" {}
variable "project" {}
```
### Create a provider.tf file 
```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```
### Create a vpc.tfvars
By default terraform.tfvars will load the variables to the reources.
You can modify accordingly as per your requirements.
```sh
region     = "write-your-region-here"
access_key = "your-access-key"
secret_key = "your-secret-key"
project = "name-of-your-project"
vpc_cidr = "X.X.X.X/X"
```
next initialize the working directory containing Terraform configuration files using below command
```sh
terraform init
```
#### Lets start creating main.tf file with the details below.
> To create a vpc
```sh
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr 
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-vpc"
  }
}
```
### create an Internet gateway for vpc
```sh
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}
```
> To creating subnets for public newwork
```sh
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 0)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
  }
}
```
> public subnet2
```sh
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 1)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[1]

  tags = {
    Name = "${var.project}-public2"
  }
}
```
> public subnet3
```sh
resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 2)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
  }
}
```
> Creating private Subnet1
```sh
resource "aws_subnet" "private1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, 3, 3)
  availability_zone        = element(data.aws_availability_zones.available.names,3)
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private1"
  }
}
```
> Creating private2 Subnet
```sh
resource "aws_subnet" "private2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, 3, 4)
  availability_zone        = element(data.aws_availability_zones.available.names,4)
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private2"
  }
}
```
> Creating private3 Subnet
```sh
resource "aws_subnet" "private3" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, 3, 5)
  availability_zone        = element(data.aws_availability_zones.available.names,5)
  map_public_ip_on_launch  = false
  tags = {
    Name = "${var.project}-private3"
  }
}
```
> Create a route table for public network
```sh
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.project}-public"
  }
}
```
> associate public subnets to route table.
```sh
resource "aws_route_table_association" "public1" {        
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {      
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public3" {       
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
```
> creating an Elastic IP for NAT gateway
```sh
resource "aws_eip" "ip" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}
```
> Creating NAT gateway
```sh
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public2.id
  tags = {
    Name = "${var.project}-nat"
  }
}
```
>  Creating Private Route Table
```sh
  resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project}-private"
  }
}
```
> Creating Private Route Table Association
```sh
resource "aws_route_table_association" "private1" {        
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {      
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private3" {       
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
````
----
## Conclusion
That’s all. All you need to follow below these steps and clone this repository to start terraform.

Note: modify vpc.tfvars values accordingly as per your requirements.

After cloning the repo to th project directoy, just run these 3 commands.
```sh
terraform init 
terraform plan 
terraform apply
```
