resource "aws_security_group" "sg_db" {
  name = "SG_DB_Terraform"
  description = "a security group created by terraform, supposed to let the db communicate with the app"

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
     cidr_blocks = ["172.31.0.0/16"]
   }

  ingress {
    description = "SSH from nodejs_app_instance"
    from_port = 22
    to_port = 22
    protocol = "tcp"
     # hard coded nodejs_app_instance private ip, need to automate
     cidr_blocks = ["172.31.0.0/16"]
   }

   egress {
     from_port = 0
     to_port = 0
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
}
