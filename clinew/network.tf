# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidrblock
}
#creating a subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.sub_cidr
  availability_zone = var.az_zones
  tags = {
    Name = "subnetnew"
  }
  depends_on = [
    aws_vpc.my_vpc
  ]
}
#creating a internetgateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "igw"
  }
}

#creating route table
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "routetable"
  }
}

#creating routetable association
resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route.id
}

#creating route
resource "aws_route" "route" {
  route_table_id            = aws_route_table.route.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id


}

#creating security group 
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = "22"
    to_port          = "22"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = "443"
    to_port          = "443"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  egress {
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_ports"
  }
}

#creating launch template
resource "aws_launch_template" "instance" {
   name = "packer_ami_instance"
   network_interfaces {
     subnet_id             = aws_subnet.subnet1.id
     security_groups       = [aws_security_group.allow_tls.id]
     associate_public_ip_address = true
}
   block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 8
    }
  }
   image_id = var.ami_id
   instance_type = var.instancetype
   key_name = var.key_name
   placement {
    availability_zone = "us-west-2a"
  }
  	#vpc_security_group_ids = [ "sg-0694f2d6589b20d43" ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "autoscalinginstance"
    }
  }
}
  #creating autoscaling_group
resource "aws_autoscaling_group" "packer"{
  name                       = "autoscaling_group_for_instance"
  availability_zones         = ["us-west-2a"]
  max_size                   = "5"
  min_size                   = "1"
  health_check_grace_period  = "300"
  health_check_type          = "ELB"
  desired_capacity           = "2"
  #force_delete               = true
   launch_template{
        id = aws_launch_template.instance.id
        version = "$Latest"
      }
    
}











