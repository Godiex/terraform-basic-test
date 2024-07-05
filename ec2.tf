variable "instance_type" {
  default = "t2.nano"
}

variable "ami" {
  default = "ami-0c55b159cbfafe1f0"
}

variable "key_name" {
  description = "este el nombre de la key a usar ssh access"
  default = "ec2-tf-2"
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

resource "aws_lb" "lb_ec2" {
  name = "lb-ec2"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb_sg.id]
  subnets = [aws_subnet.public1.id, aws_subnet.public2.id]
  tags = {
    Name = "lb-ec2"
  }
}

resource "aws_lb_target_group" "target-group" {
  name = "my-targets-lb"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  
  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }

  tags = {
    Name = "my-target-group"
  }
  
}

resource "aws_lb_target_group_attachment" "target-web1" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.web1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "target-web2" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.web2.id
  port = 80
}

resource "aws_lb_listener" "http_lb" {
  load_balancer_arn = aws_lb.lb_ec2.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}
