variable "instance_type" {
  default = "t2.nano"
}

variable "ami" {
  default = "ami-0c55b159cbfafe1f0"
}

variable "key_name" {
  description = "este el nombre de la key a usar ssh access"
  default = "ec2-tf"
}

resource "aws_instance" "web1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id]
  key_name = var.key_name
  tags = {
    Name = "ec2-tf-1"
  }
}

resource "aws_instance" "web2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.allow_all.id, aws_security_group.allow_ssh.id]
  key_name = var.key_name
  tags = {
    Name = "ec2-tf-2"
  }
}
