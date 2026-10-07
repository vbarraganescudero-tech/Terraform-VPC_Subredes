# Publica

resource "aws_internet_gateway" "victor_igw" {
    vpc_id = aws_vpc.victor_vpc.id
    tags = {
        Name = var.nombre_igw
    }
}   


# Privada
# eip
resource "aws_eip" "victor_eip" {
    domain = "vpc"
    tags = {
        Name = var.nombre_eip
    }
}

# NAT
resource "aws_nat_gateway" "victor_nat_gw" {
    allocation_id = aws_eip.victor_eip.id
    subnet_id     = aws_subnet.victor_subnet_public.id
    tags = {
        Name = var.nombre_nat_gw
    }
}