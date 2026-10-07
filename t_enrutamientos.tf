
resource "aws_route_table" "victor_public_rt" {
    vpc_id = aws_vpc.victor_vpc.id

    route {
        cidr_block = var.cidr_origen_ruta
        gateway_id = aws_internet_gateway.victor_igw.id
    }
    tags = {
        Name = var.nombre_pub_rt
    }
}   

resource "aws_route_table_association" "victor_public_rt_assoc" {
    subnet_id      = aws_subnet.victor_subnet_public.id
    route_table_id = aws_route_table.victor_public_rt.id
}  


# Privada

resource "aws_route_table" "victor_private_rt" {
    vpc_id = aws_vpc.victor_vpc.id

    route {
        cidr_block     = var.cidr_origen_ruta
        nat_gateway_id = aws_nat_gateway.victor_nat_gw.id
    }
    tags = {
        Name = var.nombre_priv_rt
    }
}

resource "aws_route_table_association" "victor_private_rt_assoc" {
    subnet_id      = aws_subnet.victor_subnet_private.id
    route_table_id = aws_route_table.victor_private_rt.id
}