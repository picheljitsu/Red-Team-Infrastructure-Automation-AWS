# configure http c2 firewall
variable "vpc_id" {}
variable "security_groups" {}

resource "aws_security_group" "red_team" {
    for_each = var.security_groups
    name = each.key
    description = each.value.description
    vpc_id = var.vpc_id
    tags = { 
      Name = each.key
    }
    
    ingress {
        description = each.value.ingress.description
        from_port   = each.value.ingress.from_port
        to_port     = each.value.ingress.to_port
        protocol    = each.value.ingress.protocol
        cidr_blocks = each.value.ingress.cidr_blocks
    }

    egress {
        description      = each.value.egress.description
        from_port        = each.value.egress.from_port
        to_port          = each.value.egress.to_port
        protocol         = each.value.egress.protocol
        cidr_blocks      = each.value.egress.cidr_blocks
        ipv6_cidr_blocks = each.value.egress.ipv6_cidr_blocks
    }
}

output "id" {
    value = aws_security_group.red_team
}
