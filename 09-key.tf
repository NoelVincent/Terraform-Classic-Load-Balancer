###############################################################################
# Keypair Creation
###############################################################################


resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("terraform.pub")
  tags = {
    Name = "${var.project}-key"
    Project = var.project
  }
}
