variable "region_aws" {
  description = "region estancia"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "cidr de la vpc principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nombre_vpc" {
  description = "nombre de la vpc"
  type        = string
  default     = "victor_vpc"
}

variable "nombre_igw" {
  description = "Nombre para el Internet Gateway"
  type        = string
  default     = "victor_igw"
}

variable "nombre_eip" {
  description = "Nombre para la Elastic IP"
  type        = string
  default     = "victor_eip"
}

variable "nombre_nat_gw" {
  description = "Nombre para el NAT Gateway"
  type        = string
  default     = "victor_nat_gw"
}

variable "nombre_pub_rt" {
  description = "Nombre para la tabla de rutas pública"
  type        = string
  default     = "victor_pub_rt"
}

variable "nombre_priv_rt" {
  description = "Nombre para la tabla de rutas privada"
  type        = string
  default     = "victor_priv_rt"
}

variable "cidr_origen_ruta" {
  description = "Bloque CIDR por defecto para salir a internet (ruta por defecto)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "nombre_subnet_pub" {
  description = "Nombre de la subnet publica"
  type        = string
  default     = "victor_subnet_publica"
}

variable "cidr_subnet_pub" {
  description = "bloque cidr para la subnet publica"
  type        = string
  default     = "10.0.1.0/24"
}

variable "nombre_subnet_piv" {
  description = "Nombre de la subnet privada"
  type        = string
  default     = "victor_subnet_privada"
}

variable "cidr_subnet_priv" {
  description = "bloque cidr para la subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "region_subnet" {
  description = "region estancia"
  type        = string
  default     = "us-east-1a"
}