# Publica

resource "aws_subnet" "victor_subnet_public" {
    vpc_id                  = aws_vpc.victor_vpc.id
    cidr_block              = var.cidr_subnet_pub
    availability_zone       = var.region_subnet
    map_public_ip_on_launch = true
    tags = {
        Name = var.nombre_subnet_pub
    }
}

# Privada

resource "aws_subnet" "victor_subnet_private" {
    vpc_id                  = aws_vpc.victor_vpc.id
    cidr_block              = var.cidr_subnet_priv
    availability_zone       = var.region_subnet
    tags = {
        Name = var.nombre_subnet_piv
    }
}       


