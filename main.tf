# tell which cloud provider is required
provider "aws" {
  region = var.region
}

resource "aws_instance" "nodejs_app_instance" {
  # ami_id of the app image created by packer
  ami = var.nodejs_app_ami
  instance_type = "t2.micro"
  associate_public_ip_address = true
  # associate with an already made security group with the relevant rules
  security_groups = ["eng74-amaan-SG_APP_Terraform"]
  tags = {
    Name = "eng74-amaan-nodeapp_terraform"
  }
  key_name = var.key_name

  provisioner "start_app" {
    inline = [
      "cd /home/ubuntu/app && sudo pm2 start app.js"
    ]
  }
}

resource "aws_instance" "mongodb_instance" {
  ami = var.mongodb_ami
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["SG_DB_Terraform"]
  tags = {
    Name = "eng74-amaan-DB_terraform"
  }
  key_name = "eng74-amaan-aws"

  provisioner "start_db" {
    inline = [
      "sudo systemctl enable mongod.service --now"
    ]
  }
}

output "ip" {
  value = [aws_instance.nodejs_app_instance.*.public_ip, aws_instance.nodejs_app_instance.*.private_ip]
}

output "mongod_ip" {
  value = [aws_instance.mongodb_instance.*.public_ip, aws_instance.mongodb_instance.*.private_ip]
}
