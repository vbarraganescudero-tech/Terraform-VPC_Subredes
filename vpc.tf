resource "aws_vpc" "victor_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    tags = {
        Name = var.nombre_vpc
    }
}