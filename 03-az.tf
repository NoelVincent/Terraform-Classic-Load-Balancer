###################################################################
# Fetching Availability Zones
###################################################################


data "aws_availability_zones" "az" {
  state = "available"
}

output "availability_names" {    
  value = data.aws_availability_zones.az.names
}
