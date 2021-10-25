# Creating a Classic Load Balancer using Terraform
Here, I am creating a VPC first with 3 public subnets along with Internet Gateway and a Public Route Table. Then will be creating a Lauch Configuration, Classic Load Balancer and Auto Scaling Group.

## Terraform
Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.
https://www.terraform.io/

## Installing Terraform
- Create an IAM user on your AWS console and give access to create the required resources.
- Create a directory where you can create terraform configuration files.
- Download Terrafom, click here [Terraform](https://www.terraform.io/downloads.html).
- Install Terraform, click here [Terraform installation](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

##### Command to install Terraform
```sh
# wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
# unzip terraform_1.0.8_linux_amd64.zip
# mv terraform /usr/local/bin/

# terraform version   =======> To check the version
Terraform v1.0.8
on linux_amd64
```

> Note : The terrafom files must be created with .tf extension as terraform can only execute .tf files
> https://www.terraform.io/docs/language/files/index.html

### Terraform commands

#### Terraform Validation
> This will check for any errors on the source code

```sh
terraform validate
```
#### Terraform Plan
> The terraform plan command provides a preview of the actions that Terraform will take in order to configure resources per the configuration file. 

```sh
terraform plan
```
#### Terraform apply
> This will execute the tf file that we created

```sh
terraform apply
```
https://www.terraform.io/docs/cli/commands/index.html

## 1. Declaring Variables
This is used to declare the variable and pass values to terraform source code.
```sh
vim variable.tf
```
##### Declare the variables for initialising terraform
```sh
variable "project" {
  default = "test"
}

variable "access_key"{
  default = " "           #==========> provide the access_key of the IAM user
}

variable "secret_key"{
  default = " "          #==========> provide the secret_key of the IAM user
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "vpc_subnets" {
  default = "3"
}

variable "type" {
  description = "Instance type"    
  default = "t2.micro"
}

variable "ami" {
  description = "amazon linux 2 ami"
  default = "ami-041d6256ed0f2061c"
}

variable "asg_count" {
	  default = 2
}
```
##### Creating a variable.tfvars
> Note : A terraform.tfvars file is used to set the actual values of the variables.
```sh
vim variable.tfvars
```
```sh
project     = " Your project name"
access_key  = "IAM user access_key"
secret_key  = "IAM user secret_key"
vpc_cidr    = "VPC cidr block"
```

## 2.  Create the provider file
> Terraform configurations must declare which providers they require, so that Terraform can install and use them. I'm using AWS as provider
```sh
vim provider.tf
```
```sh
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
```

## 3. Fetching Availability Zones in working AWS region
> This will fetch all available Availability Zones in working AWS region and store the details in variable az
```sh
vim az.tf
```
```sh
data "aws_availability_zones" "az" {
  state = "available"
}

output "availability_names" {    
  value = data.aws_availability_zones.az.names
}
```
> I have also added output in this file so that I could get an ouput when I run the command
```sh
terrafrom output
```
https://www.terraform.io/docs/cli/commands/output.html

## 4. Creating VPC
- Create VPC resource
```sh
vim vpc.tf
```
```sh
resource "aws_vpc" "vpc" {
    
  cidr_block            =  var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "${var.project}-vpc"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```
## 5. Creating and Attaching Internet GateWay
```sh
vim igw.tf
```
```sh
resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```

## 6. Creating Public subents
```sh
vim subnet.tf
```
```sh
###################################################################
# Creating Public Subnet1
###################################################################

resource "aws_subnet" "public1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet2
###################################################################

resource "aws_subnet" "public2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet3
###################################################################

resource "aws_subnet" "public3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```
## 7. Creating Public Route Table
```sh
resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-public-rtb"
    Project = var.project
  }
}
```

## 8. Route Table Association
```sh
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
```
## 9. Creating Security Group
```sh
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
```
- Allows all traffic from anywhere.

# 10. Creating a key pair
- First generate a key using the following command and enter a file in which to save the key
```sh
ssh-keygen
```
> Here, I used the file name as terraform
```sh
resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("terraform.pub")
  tags = {
    Name = "${var.project}-key"
    Project = var.project
  }
}
```
# 11. Creating a Classic Load Balancer
> A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.

The following diagram illustrates the basic components. 

![alt text](https://i.ibb.co/bWXzc7S/1.png[/img)

- Elastic Load Balancing/Classic Load Balancer can scale to the vast majority of workloads automatically.
- A listener checks for connection requests from clients, using the protocol and port that you configure, and forwards requests to one or more registered instances using the protocol and port number that you configure. You add one or more listeners to your load balancer.

##### Creating the Classic Load Balancer
```sh
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
```
# 12. Creating Launch Configuration
> Need to create a user data for the lauch configuration first
```sh
vim setup.sh
```
```sh
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
service sshd restart

echo "password123" | passwd root --stdin
sed  -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart

yum install httpd php -y
systemctl enable httpd
systemctl restart httpd

cat <<EOF > /var/www/html/index.php
<?php
\$output = shell_exec('echo $HOSTNAME');
echo "<h1><center><pre>\$output</pre></center></h1>";
echo "<h1><center><pre>  Version 1 </pre></center></h1>";
?>
EOF
```
##### Launch Configuration
```sh
vim lc.tf
```
```
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
```

# 13. Creating Auto Scale Group
```sh
vim asg.tf
```
```sh
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
```
# Conclusion
Here is a simple document on how to use Terraform to build an AWS Classic Load Balancer
