# tell which cloud provider is required
provider "aws" {
  region = var.region
}

# Create  a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "23.15.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "eng74-amaan-VPC_Terraform"
  }
}

# Create an IGW
resource "aws_internet_gateway" "gw" {
  # automatically assign it
  # aws_vpc.name_assigned.id
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "eng74-amaan-IGW_Terraform"
  }
}

# Create a subnet
resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "23.15.1.0/24"
  #   don't really need it here if in the aws_instance resouce (associate_public_ip_address)
  map_public_ip_on_launch = true
  tags = {
    Name = "eng74-amaan-Public_Subnet_Terraform"
  }
}


# route table for the public subnet IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eng74-amaan-Public_RT_Terraform"
  }
}


# configuring the route table association
resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_rt.id
}

# create an NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_public.id]

  egress {
    protocol = "all"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  # allow 27017 to the private subnet
  egress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "23.15.2.0/24"
    from_port = 27017
    to_port = 27017
  }

  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  ingress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  ingress {
    protocol = "tcp"
    rule_no = 400
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  ingress {
    protocol = "tcp"
    rule_no = 500
    action = "allow"
    cidr_block = "81.104.154.91/32"
    from_port = 22
    to_port = 22
  }

  tags = {
    Name = "eng74-amaan-NACL_Public_Terraform"
  }
}

# create private subnet
resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "23.15.2.0/24"
  tags = {
    Name = "eng74-amaan-Subnet_Private_Terraform"
  }
}

# NACLs for Private subnet
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet_private.id]

  # allow SSH from public subnet
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 22
    to_port = 22
  }

  # allow 27017 from public subnet
  ingress {
    protocol = "tcp"
    rule_no = 110
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 27017
    to_port = 27017
  }


  # allow ephemeral to public subnet
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "23.15.1.0/24"
    from_port = 1024
    to_port = 65535
  }

  tags = {
    Name = "eng74-amaan-NACL_Private_NACL"
  }
}

#database instance
resource "aws_instance" "mongodb_instance" {
  ami = var.mongodb_ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_private.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  key_name = var.key_name
  tags = {
    Name = "eng74-amaan-DB_terraform"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.aws_key_path)
    host = "${self.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable mongod.service --now"
    ]
  }
}

# nodejs app instance
resource "aws_instance" "nodejs_app_instance" {
  # ami_id of the app image created by packer
  ami = var.nodejs_app_ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_public.id
  associate_public_ip_address = true
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  tags = {
    Name = "eng74-amaan-nodeapp_terraform"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = {file(var.aws_key_path)
    host = "${self.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
      "cd /home/ubuntu/app",
      "sudo npm install && sudo pm2 start app.js"
    ]
  }
}


output "ip" {
  value = [aws_instance.nodejs_app_instance.*.public_ip, aws_instance.nodejs_app_instance.*.private_ip]
}

output "mongod_ip" {
  value = [aws_instance.mongodb_instance.*.public_ip, aws_instance.mongodb_instance.*.private_ip]
}
