resource "aws_security_group" "sg_app" {
  name = "eng74-amaan-SG_APP_Terraform"
  description = "Allows the app to communicate with the db etc on public subnet"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["81.104.154.91/32"]
  }

  ingress {
    description = "HTTP for updates"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for updates"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


   egress {
     from_port = 0
     to_port = 0
     protocol = -1
     cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng74-amaan-SG_APP_Terraform"
  }
}


resource "aws_security_group" "sg_db" {
  name = "eng74-amaan-SG_DB_Terraform"
  description = "a security group created by terraform, supposed to let the db communicate with the app"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTP for updates"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for updates"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
     description = "For the MongoDB communication"
     from_port = 27017
     to_port = 27017
     protocol = "tcp"
     # hard coded nodejs_app_instance private ip, need to automate
     cidr_blocks = ["23.15.0.0/16"]
   }

  ingress {
    description = "SSH from me"
    from_port = 22
    to_port = 22
    protocol = "tcp"
     # hard coded nodejs_app_instance private ip, need to automate
    cidr_blocks = ["81.104.154.91/32"]
   }

   egress {
     from_port = 0
     to_port = 0
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng74-amaan-SG_DB_Terraform"
  }
}

