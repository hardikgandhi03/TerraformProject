resource "aws_vpc" "myVPC" {
    cidr_block = var.cidr_vpc
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = var.cidr_sub1
    availability_zone = var.az_sub1
    map_public_ip_on_launch = var.mapPublicIPonlaunch
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = var.cidr_sub2
    availability_zone = var.az_sub2
    map_public_ip_on_launch = var.mapPublicIPonlaunch
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id
}

resource "aws_route_table" "routeTable" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = var.routeTableCIDR
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "routeTableAssociation1" {
    route_table_id = aws_route_table.routeTable.id
    subnet_id = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "routeTableAssociation2" {
    route_table_id = aws_route_table.routeTable.id
    subnet_id = aws_subnet.subnet2.id
}

resource "aws_security_group" "websg" {
  name        = "securitygrp_websg"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Web-sg"
  }
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucketName
}


resource "aws_instance" "webServer1" {
  ami = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.subnet1.id
  user_data = base64encode(file("userdata.sh"))
}

 resource "aws_instance" "webServer2" {
  ami = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.subnet2.id
  user_data = base64encode(file("userdata1.sh"))
}

resource "aws_lb" "myalb" {
  name               = "my-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]

tags = {
  name = "web"
}
}

resource "aws_lb_target_group" "targetgrp" {
  name = "my-Target-Group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myVPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#Check how we can give multiple id in target_id field

# resource "aws_lb_target_group_attachment" "attach1" {
#    target_group_arn = aws_lb_target_group.targetgrp.arn
#    target_id = [aws_instance.webServer1.id,aws_instance.webServer2.id]
#    port = 80
# }

resource "aws_lb_target_group_attachment" "attach1" {
   target_group_arn = aws_lb_target_group.targetgrp.arn
   target_id = aws_instance.webServer1.id
   port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
   target_group_arn = aws_lb_target_group.targetgrp.arn
   target_id = aws_instance.webServer2.id
   port = 80
}
 
 resource "aws_lb_listener" "listener" {
   load_balancer_arn = aws_lb.myalb.arn
   port = 80
   protocol = "HTTP"

   default_action {
     target_group_arn = aws_lb_target_group.targetgrp.arn
     type = "forward"
   }
 }

 output "loadBalancerDNS" {
   value = aws_lb.myalb.dns_name
 }