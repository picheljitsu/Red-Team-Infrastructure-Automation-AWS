variable "instance_configs" {}
variable "mission-name" {}
variable "aws-vpc-id" {}
variable "subnet_id" {}
variable "aws-sec-gp" {}
variable "key_name" {
  
}

resource "aws_instance" "base" {

  for_each = var.instance_configs
  ami = each.value.image
  key_name = var.key_name
  instance_type = each.value.instance_type
  #vpc_security_group_ids = []
  subnet_id = var.subnet_id
  tags = { 
    Name = each.key
  }


  # provisioner "remote-exec" {
    # inline = [
    #     "apt update",
    #     "apt-get -y install zip default-jre",
    #     "cd /opt; wget ${var.csDownloadUrl} -O cobaltstrike.zip",
    #     "echo \"@reboot root cd /opt/cobaltstrike/; ./teamserver ${aws_instance.c2-http.ipv4_address} ${var.cspw}\" >> /etc/cron.d/mdadm",
    #     "unzip -P ${var.cspw} cobaltstrike.zip && shutdown -r"
    # ]
  # }
  root_block_device {
    volume_size           = each.value.volume_size
    volume_type           = each.value.volume_type
    delete_on_termination = each.value.delete_on_termination
    # encrypted             = each.value.encrypted
    # kms_key_id            = each.value.kms_key_id == ""
  }    

}

# output "c2-http-ipv4" {
#   value = aws_instance.base.public_ip
# }

