variable "aws_region" {
  description = "Región de AWS para el despliegue"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre de la key pair de AWS para SSH"
  type        = string
}

variable "app_port" {
  description = "Puerto de la aplicación"
  type        = number
  default     = 5000
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {
    Project = "terraform-ansible-flask"
    Owner   = "Educomser"
  }
}