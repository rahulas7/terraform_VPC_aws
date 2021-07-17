##############################
# VPC Creation
##############################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr 
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

###############################
# Internet Gateway
###############################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

##############################
# Subnet Public 1
##############################

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 0)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "${var.project}-public1"
  }
}

##############################
# Subnet Public 2
##############################

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 1)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[1]

  tags = {
    Name = "${var.project}-public2"
  }
}

##############################
# Subnet Public 3
##############################

resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 2)
  map_public_ip_on_launch  = true
  availability_zone = data.aws_availability_zones.az.names[2]

  tags = {
    Name = "${var.project}-public3"
  }
}

##############################
# Subnet Private 1
##############################

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 3)
  map_public_ip_on_launch  = false
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "${var.project}-private1"
  }
}

##############################
# Subnet Private 2
##############################

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 4)
  map_public_ip_on_launch  = false
  availability_zone = data.aws_availability_zones.az.names[1]

  tags = {
    Name = "${var.project}-private2"
  }
}

##############################
# Subnet Private 3
##############################

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 3, 5)
  map_public_ip_on_launch  = false
  availability_zone = data.aws_availability_zones.az.names[2]

  tags = {
    Name = "${var.project}-private3"
  }
}

#################################
# Route Table for public network
#################################
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

##################################
# Rout table association public 1
##################################

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

##################################
# Rout table association public 2
##################################

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

##################################
# Rout table association public 3
##################################

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}

#################################
# Elastic IP
#################################

resource "aws_eip" "ip" {
  vpc      = true
  tags = {
    Name = "${var.project}-eip"
}
}

##################################
# NAT GATEWAY FOR PRIVATE SUBNETS
##################################

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "${var.project}-NAT"
  }
}

#################################
# Route Table for private network
#################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
   tags = {
    Name = "${var.project}-private"
  }
}

##################################
# Rout table association private 1
##################################

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

##################################
# Rout table association private 2
##################################

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

##################################
# Rout table association private 3
##################################

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}

