resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "terr_aws_sg" {
  name               = "terr_sg"
  vpc_id             = aws_default_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "terr_aws_instance" {
  ami                    = var.aws_ami_id
  instance_type          = var.aws_instance_type
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.terr_aws_sg.id]
  tags                   = {
    Name = "Master"
  }
}

resource "null_resource"  "master_ip" {
  depends_on = [
    aws_instance.terr_aws_instance
  ]
  provisioner "local-exec" {
    command = "echo \"[master_node]\n${aws_instance.terr_aws_instance.public_ip} ansible_ssh_private_key_file=${var.aws_key_location} ansible_ssh_user=ec2-user\n\n[slave_nodes]\" > ../inventory.txt"
  }
}