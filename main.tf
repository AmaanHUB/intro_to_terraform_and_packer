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

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "eng74-amaan-Private_RT_Terraform"
  }
}


# configuring the route table association
resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_rt.id
}

# configuring private route table association
resource "aws_route_table_association" "private_subnet_asso" {
  subnet_id = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private_rt.id
}


# create private subnet
resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "23.15.2.0/24"
  tags = {
    Name = "eng74-amaan-Subnet_Private_Terraform"
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

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable mongod.service --now"
    ]
    connection {
     type = "ssh"
     user = "ubuntu"
     private_key = file(var.aws_key_path)
     host = self.public_ip
    }
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



  provisioner "remote-exec" {
    inline = [
      "export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
      "cd /home/ubuntu/app",
      "sudo npm install && sudo pm2 start app.js"
    ]
    connection {
     type = "ssh"
     user = "ubuntu"
     private_key = file(var.aws_key_path)
     host = self.public_ip
    }
  }

  depends_on = [aws_instance.mongodb_instance]
}


output "ip" {
  value = [aws_instance.nodejs_app_instance.*.public_ip, aws_instance.nodejs_app_instance.*.private_ip]
}

output "mongod_ip" {
  value = [aws_instance.mongodb_instance.*.public_ip, aws_instance.mongodb_instance.*.private_ip]
}
