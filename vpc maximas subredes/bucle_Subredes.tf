provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "victorbuclesubred_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "victorbuclesubred_vpc"
  }
}

locals {
  subredes = {
    for i in range(256) : 
    i + 1 => cidrsubnet(aws_vpc.victorbuclesubred_vpc.cidr_block, 8, i)
  }
}

resource "aws_subnet" "victorbuclesubred_subnets" {
  for_each = local.subredes

  vpc_id     = aws_vpc.victorbuclesubred_vpc.id
  cidr_block = each.value

  tags = {
    Name = "victorbuclesubred_subred_${each.key}"
  }
}
