########################################
# Classic load balancer creating
########################################

resource "aws_elb" "classic" {
  name    = "classic-lc"
  subnets = [aws_subnet.public1.id, aws_subnet.public2.id]

listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port= 80
    lb_protocol= "http"
  }

security_groups = [aws_security_group.all-traffic.id]

health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout= 3
    target= "TCP:80"
    interval= 30
  }

  tags = {
    Name = "${var.project}-classic-LB"
  }

lifecycle {
    create_before_destroy = true
  }
}


output "dns_name" {    
  value = aws_elb.classic.dns_name
}
