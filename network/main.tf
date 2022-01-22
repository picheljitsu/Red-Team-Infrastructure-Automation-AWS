#Set network configs after deploying instances
variable "vpc-id" {}
variable "network-configs" {}
# resource "aws_eip_association" "elastic_ip" {
#   instance_id   = aws_instance.c2-http-rdr.id
#   allocation_id = aws_eip.c2-http-rdr.id
# }

resource "aws_subnet" "red_net" {
  for_each = var.network-configs
  vpc_id = ""
  cidr_block = ""
  map_public_ip_on_launch = "false"
  availability_zone = ""
  tags = {
    name = ""
  }
}


# resource "aws_eip" "example" {
#   vpc = true
# }