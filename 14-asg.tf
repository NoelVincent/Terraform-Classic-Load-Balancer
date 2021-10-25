#######################################################
# ASG
#######################################################
resource "aws_autoscaling_group" "asg" {

  launch_configuration    =  aws_launch_configuration.test-lc.id
  vpc_zone_identifier     = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type       = "EC2"
  min_size                = var.asg_count
  max_size                = var.asg_count
  desired_capacity        = var.asg_count
  wait_for_elb_capacity   = var.asg_count
  load_balancers          = [aws_elb.classic.id]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "test-asg"
  }
  lifecycle {
    create_before_destroy = true
  }
}
