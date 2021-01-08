# tell which cloud provider is required
provider "aws" {
  region = var.region
}

# myip module
module "myip" {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

#database instance
resource "aws_instance" "mongodb_instance" {
  ami = var.mongodb_ami
  instance_type = "t2.micro"
  # putting in public for now
  subnet_id = aws_subnet.subnet_public.id
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
      "cd /home/ubuntu/app",
      "sudo npm run seeds/seed.js"
      "sudo npm install && sudo DB_HOST=${aws_instance.mongodb_instance.private_ip} pm2 start app.js"
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
