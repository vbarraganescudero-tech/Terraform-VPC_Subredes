> Primer ejercicio:

# <center> Creacion de subredes Publicas y Privadas. </center>


> Primero definimos el proveedor de AWS y la región donde se desplegará la infraestructura. Luego, crearemos un VPC con un bloque CIDR específico, seguido de la creación de subredes públicas y privadas dentro de ese VPC. También configuraremos una tabla de rutas para las subredes públicas y privadas, y finalmente, crearemos un gateway de Internet para permitir el acceso a Internet desde las subredes públicas. 


---

> Proveedor de aws :

```hcl
provider "aws" {
    region = "us-east-1"  
    // Región de AWS donde se creará toda la infraestructura
}
```

---

> Creacion de la VPC

```hcl 
resource "aws_vpc" "victor_vpc" {
// Rango total de IPs disponibles para toda la red 
  cidr_block           = "10.0.0.0/16" 
// Activa el soporte de resolución DNS interna de AWS
  enable_dns_support   = true          
// Permite que los recursos reciban nombres de host DNS públicos
  enable_dns_hostnames = true          

  tags = {
// Etiqueta para identificar la VPC en la consola de AWS
    Name = "victor_vpc" 
  }
}
```

---

> Creacion de la Gateway

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway"> terraform.io gateway </a>

```hcl 
resource "aws_internet_gateway" "victor_igw" {
// Conecta este Gateway directamente a nuestra VPC
  vpc_id = aws_vpc.victor_vpc.id 

  tags = {
    Name = "victor-igw"
  }
}

```

---

> Subredes:

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet"> terraform.io Subnet</a>


> Creacion de la Subred Pública

```hcl 
resource "aws_subnet" "publica" {
// Indica que pertenece a nuestra VPC
  vpc_id                  = aws_vpc.victor_vpc.id  
// Segmento de IPs asignado a esta subred
  cidr_block              = "10.0.1.0/24"      
// Hace que cualquier recurso aquí tenga IP pública automática
  map_public_ip_on_launch = true               
// Zona física de AWS donde se ubicará
  availability_zone       = "us-east-1a"   

  tags = {
    Name = "subred-publica"
  }
}

```

> Creacion de la Subred Privada

```hcl 

resource "aws_subnet" "privada" {
// Indica que pertenece a nuestra VPC
  vpc_id            = aws_vpc.victor_vpc.id 
// Segmento de IPs diferente para no colisionar con la pública
  cidr_block        = "10.0.2.0/24"      
// Ubicada en la misma zona física (o puedes cambiarla a us-east-1b)
  availability_zone = "us-east-1a"

// NOTA: Al NO tener 'map_public_ip_on_launch', los recursos aquí nacen sin IP pública (aislados)

  tags = {
    Name = "subred-privada"
  }
}

```
---

> Tablas de enrutamientos

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table"> terraform.io Tablas de enrutamiento</a>

```hcl 

resource "aws_route_table" "publica_ruta" {
  vpc_id = aws_vpc.victor_vpc.id

// Regla de enrutamiento:
  route {
// Significa "cualquier destino fuera de la VPC"
    cidr_block = "0.0.0.0/0" 
// Envía ese tráfico hacia el Internet Gateway creado arriba
    gateway_id = aws_internet_gateway.victor_igw.id
  }

  tags = {
    Name = "publica_ruta"
  }
}

```

---

> Asociación de la tabla

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association"> terraform.io Asociacion de tablas</a>

```hcl
resource "aws_route_table_association" "assoc_publica" {
// Tomamos la subred pública...
  subnet_id      = aws_subnet.publica.id   
// Le aplicamos el mapa de rutas con salida a Internet.  
  route_table_id = aws_route_table.publica_ruta.id 

// NOTA: La subred privada no se asocia aquí; por eso se queda usando la tabla interna por defecto.
}
```
---

# <center> Salida a internet para las subredes privadas para las descargas de paqueteria: </center>

> IP Pública Estática (Elastic IP) requerida obligatoriamente por el NAT Gateway

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip"> terraform.io IP Pública Estática</a>

```hcl
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
```
--- 

> El NAT Gateway colocado en la subred pública para hacer de intermediario

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway"> terraform.io IP NAT Gateway</a>

```hcl
resource "aws_nat_gateway" "victor_nat" {
// sirve para vincular tu IP Pública fija (Elastic IP) al NAT Gateway.
  allocation_id = aws_eip.nat_eip.id
// El NAT siempre debe vivir en la subred pública
  subnet_id     = aws_subnet.publica.id 

  tags = {
    Name = "victor-nat-gateway"
  }

// Evitar que el NAT se intente crear antes de que el IGW esté listo
  depends_on = [aws_internet_gateway.victor_igw]
}
```
---

> Nueva tabla de rutas exclusiva para que la subred privada sepa llegar al NAT Gateway
>
Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table"> terraform.io Tablas de enrutamiento</a>

```hcl
resource "aws_route_table" "privada_ruta" {
  vpc_id = aws_vpc.victor_vpc.id

  route {
// Cualquier petición externa (ej. descargar paquetes)
    cidr_block     = "0.0.0.0/0"   
// Se envía a través del NAT Gateway de forma segura               
    nat_gateway_id = aws_nat_gateway.victor_nat.id 
  }

  tags = {
    Name = "privada_ruta"
  }
}

```
---

> Asociación de la tabla privada con su respectiva subred

Información sacada de: <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association"> terraform.io Asociacion de tablas Gateway</a>

```hcl
resource "aws_route_table_association" "assoc_privada" {
  subnet_id      = aws_subnet.privada.id
  route_table_id = aws_route_table.privada_ruta.id
}
```
---

> Segundo ejercicio

# <center> Bucle de subredes </center>

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
