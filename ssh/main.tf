# Direct AWS to create and store an SSH key-pair
variable "key_name" {} 
variable "mission-name" {}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "setter" {
  key_name = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh
  tags = {
    "Mission" = var.mission-name
  }
}

#Get AWS key pair from AWS to validate its creation
data "aws_key_pair" "getter" {
  key_name = aws_key_pair.setter.key_name
}

#Return public key value so we can output it locally
output "public_key" {
  value = tls_private_key.rsa_key.public_key_openssh
}

output "key_name" {
  value = data.aws_key_pair.getter.key_name
}
