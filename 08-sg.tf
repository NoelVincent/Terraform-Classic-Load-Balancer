resource "aws_security_group" "all-traffic" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-all-traffic"
  description = "allow all ports"

  ingress = [
           { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-all-traffic"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = true
  }

}
