# Bucle de subredes

> Creare un bucle para ver cuantas subredes es capa de crearse en aws:
```hcl

//activo el provaider de aws
provider "aws" {
  region = "us-east-1"
}
// Creo el vpc
resource "aws_vpc" "victorbuclesubred_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "victorbuclesubred_vpc"
  }
}

locals {
  subredes = {

// No se puede crear más de 256 subredes en un VPC con un bloque CIDR /16

    for i in range(256) : 

/* sirve para calcular automáticamente el CIDR de cada subred a partir del CIDR de tu VPC. 
(cidrsubnet(VPC (Nombre), bits (siempre 8), numero (el contador i))) (el i + 1 actua como contador)*/

    i + 1 => cidrsubnet(aws_vpc.victorbuclesubred_vpc.cidr_block, 8, i)
  }
}

resource "aws_subnet" "victorbuclesubred_subnets" {
  // Crea un recurso aws_subnet por cada elemento que haya dentro de local.subredes
  for_each = local.subredes

  vpc_id     = aws_vpc.victorbuclesubred_vpc.id
  // activo aqui el bucle
  cidr_block = each.value

  tags = { 
    // aqui activo el bucle para el nombre se quede victorbuclesubred_subred_1,2,3,4...
    Name = "victorbuclesubred_subred_${each.key}"
  }
}
```
