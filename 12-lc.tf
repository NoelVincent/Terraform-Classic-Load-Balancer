#######################################################
# Launch Configuration
#######################################################


resource "aws_launch_configuration" "test-lc" {
  
  name              = "test-lc"
  image_id          = var.ami
  instance_type     = var.type
  key_name          = aws_key_pair.key.id
  security_groups   = [aws_security_group.all-traffic.id]
  user_data         = file("11-setup.sh")
  lifecycle {
    create_before_destroy = true
  }
}
