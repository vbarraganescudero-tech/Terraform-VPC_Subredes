
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "victor_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    tags = {
        Name = "victor_vpc"
    }
}

resource "aws_subnet" "victor_subnet_public" {
    vpc_id                  = aws_vpc.victor_vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "victor_subnet_public"
    }
}

resource "aws_internet_gateway" "victor_igw" {
    vpc_id = aws_vpc.victor_vpc.id
    tags = {
        Name = "victor_igw"
    }
}   

resource "aws_route_table" "victor_public_rt" {
    vpc_id = aws_vpc.victor_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.victor_igw.id
    }
    tags = {
        Name = "victor_public_rt"
    }
}   

resource "aws_route_table_association" "victor_public_rt_assoc" {
    subnet_id      = aws_subnet.victor_subnet_public.id
    route_table_id = aws_route_table.victor_public_rt.id
}   

resource "aws_subnet" "victor_subnet_private" {
    vpc_id                  = aws_vpc.victor_vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-east-1a"
    tags = {
        Name = "victor_subnet_private"
    }
}       


resource "aws_eip" "victor_eip" {
    domain = "vpc"
    tags = {
        Name = "victor_eip"
    }
}

resource "aws_nat_gateway" "victor_nat_gw" {
    allocation_id = aws_eip.victor_eip.id
    subnet_id     = aws_subnet.victor_subnet_public.id
    tags = {
        Name = "victor_nat_gw"
    }
}

resource "aws_route_table" "victor_private_rt" {
    vpc_id = aws_vpc.victor_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.victor_nat_gw.id
    }
    tags = {
        Name = "victor_private_rt"
    }
}

resource "aws_route_table_association" "victor_private_rt_assoc" {
    subnet_id      = aws_subnet.victor_subnet_private.id
    route_table_id = aws_route_table.victor_private_rt.id
}


